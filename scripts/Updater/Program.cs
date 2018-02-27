// Copyright (c) .NET Foundation. All rights reserved.
// Licensed under the Apache License, Version 2.0. See License.txt in the project root for license information.

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Xml.Linq;
using McMaster.Extensions.CommandLineUtils;
using Microsoft.DotNet.VersionTools;
using Microsoft.DotNet.VersionTools.Automation;
using Microsoft.DotNet.VersionTools.BuildManifest.Model;
using Microsoft.DotNet.VersionTools.Dependencies;
using Microsoft.DotNet.VersionTools.Dependencies.BuildOutput;
using NuGet.Versioning;

namespace UpdateDependencies
{
    class Program
    {
        static Task<int> Main(string[] args) => CommandLineApplication.ExecuteAsync<Program>(args);

        [Option(Description = "The folder to the repository root")]
        [DirectoryExists]
        public string RepoRoot { get; } = Directory.GetCurrentDirectory();

        [Option("--build-info-url", Description = "URL of the build info to update the Dockerfiles with")]
        [Required]
        public string BuildInfoUrl { get; }

        [Option("-p|--github-password", Description = "GitHub password used to make PR (if not specified, a PR will not be created)")]
        public string GitHubPassword { get; }

        [Option("-u|--github-user", Description = "GitHub user used to make PR (if not specified, a PR will not be created)")]
        public string GitHubUser { get; }

        [Option("-e|--github-email", Description = "GitHub email used to make PR (if not specified, a PR will not be created)")]
        [EmailAddress]
        public string GitHubEmail { get; }

        [Option("-b|--branch")]
        public string GitHubUpstreamBranch { get; } = "dev";

        [Option("--project")]
        public string GitHubProject { get; } = "aspnet-docker";

        [Option("--github-upstream-owner")]
        public string GitHubUpstreamOwner { get; } = "aspnet";

        private const string RuntimeBuildInfo = "aspnetcore-runtime";

        private bool IsUpdateOnly() => GitHubEmail == null || GitHubPassword == null || GitHubUser == null;

        public async Task OnExecute()
        {
            Trace.Listeners.Add(new TextWriterTraceListener(Console.Out));

            var updateResults = await UpdateFilesAsync();
            if (updateResults.ChangesDetected())
            {
                if (IsUpdateOnly())
                {
                    Trace.TraceInformation($"Changes made but no GitHub credentials specified, skipping PR creation");
                }
                else
                {
                    await CreatePullRequestAsync(updateResults);
                }
            }
        }

        private async Task<DependencyUpdateResults> UpdateFilesAsync()
        {
            var buildInfo = await GetBuildInfoAsync();
            var runtimeVersion = new NuGetVersion(buildInfo.SimpleVersion);
            var dockerfileVersion = $"{runtimeVersion.Major}.{runtimeVersion.Minor}";
            var updaters = GetUpdaters(dockerfileVersion);

            return DependencyUpdateUtils.Update(updaters, new[] { buildInfo });
        }

        private async Task<IDependencyInfo> GetBuildInfoAsync()
        {
            Trace.TraceInformation($"Retrieving build info from '{BuildInfoUrl}'");

            using (var client = new HttpClient())
            using (var stream = await client.GetStreamAsync(BuildInfoUrl))
            {
                var buildInfoXml = XDocument.Load(stream);
                var buildInfo = OrchestratedBuildModel.Parse(buildInfoXml.Root);
                var aspnetBuild = buildInfo.Builds
                    .First(build => string.Equals(build.Name, "aspnet", StringComparison.OrdinalIgnoreCase));

                return new BuildDependencyInfo(
                    new BuildInfo()
                    {
                        Name = RuntimeBuildInfo,
                        LatestReleaseVersion = aspnetBuild.ProductVersion,
                        LatestPackages = new Dictionary<string, string>()
                    },
                    false,
                    Enumerable.Empty<string>());
            }
        }


        private async Task CreatePullRequestAsync(DependencyUpdateResults updateResults)
        {
            var gitHubAuth = new GitHubAuth(GitHubPassword, GitHubUser, GitHubEmail);
            var prCreator = new PullRequestCreator(gitHubAuth, GitHubUser);
            var prOptions = new PullRequestOptions()
            {
                BranchNamingStrategy = new SingleBranchNamingStrategy($"UpdateDependencies-{GitHubUpstreamBranch}")
            };

            var runtimeVersion = updateResults.UsedInfos.First().SimpleVersion;
            var commitMessage = $"Update aspnetcore on {GitHubUpstreamBranch} to {runtimeVersion}";

            await prCreator.CreateOrUpdateAsync(
                commitMessage,
                commitMessage,
                string.Empty,
                new GitHubBranch(GitHubUpstreamBranch, new GitHubProject(GitHubProject, GitHubUpstreamOwner)),
                new GitHubProject(GitHubProject, gitHubAuth.User),
                prOptions);
        }

        private IEnumerable<IDependencyUpdater> GetUpdaters(string dockerfileVersion)
        {
            var dockerfiles = Directory.GetFiles(
                Path.Combine(RepoRoot, dockerfileVersion),
                "Dockerfile",
                SearchOption.AllDirectories);

            Trace.TraceInformation("Updating the following Dockerfiles:");
            Trace.TraceInformation(string.Join(Environment.NewLine, dockerfiles));

            return dockerfiles
                .Select(path => CreateDockerfileEnvUpdater(path, "ASPNETCORE_VERSION"));
        }

        private static IDependencyUpdater CreateDockerfileEnvUpdater(string path, string envName)
        {
            return new FileRegexReleaseUpdater()
            {
                Path = path,
                BuildInfoName = RuntimeBuildInfo,
                Regex = new Regex($"ENV {envName} (?<envValue>[^\r\n]*)"),
                VersionGroupName = "envValue"
            };
        }
    }
}
