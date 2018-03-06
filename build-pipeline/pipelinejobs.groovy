import org.dotnet.ci.pipelines.Pipeline

def windowsPipeline = Pipeline.createPipeline(this, 'windows-pipeline.groovy')

// Images that can only build on RS1, not RS3
['1.*', '2.1/nanoserver-sac2016/*', '2.1/nanoserver-sac2016/*'].each { folderFilter ->
    windowsPipeline.triggerPipelineOnEveryGithubPR(['folderFilter':folderFilter])
    windowsPipeline.triggerPipelineOnGithubPush(['folderFilter':folderFilter])
}

// Images that can only build on RS3, not RS1
['2.1/nanoserver-1709/*', '2.1/nanoserver-1709/*'].each { folderFilter ->
    windowsPipeline.triggerPipelineOnEveryGithubPR(['RS3':true, 'folderFilter':folderFilter])
    windowsPipeline.triggerPipelineOnGithubPush(['RS3':true, 'folderFilter':folderFilter])
}

def linuxPipeline = Pipeline.createPipeline(this, 'linux-pipeline.groovy')

['1.*', '2.0/*', '2.1/*'].each { folderFilter ->
    linuxPipeline.triggerPipelineOnEveryGithubPR(['folderFilter':folderFilter])
    linuxPipeline.triggerPipelineOnGithubPush(['folderFilter':folderFilter])
}
