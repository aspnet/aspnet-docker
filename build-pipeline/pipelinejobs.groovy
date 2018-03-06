import org.dotnet.ci.pipelines.Pipeline

def windowsPipeline = Pipeline.createPipeline(this, 'windows-pipeline.groovy')

// Images that can only build on RS1, not RS3
['1.*', '2.1/nanoserver-sac2016/*', '2.1/nanoserver-sac2016/*'].each { folderFilter ->
    def triggerName = "Windows SAC2016 ${folderFilter[0..-2]} Build"

    windowsPipeline.triggerPipelineOnEveryGithubPR(triggerName, ['folderFilter':folderFilter])
    windowsPipeline.triggerPipelineOnPush(triggerName, ['folderFilter':folderFilter])
}

// Images that can only build on RS3, not RS1
['2.1/nanoserver-1709/*', '2.1/nanoserver-1709/*'].each { folderFilter ->
    def triggerName = "Windows 1709 ${folderFilter[0..-2]} Build"

    windowsPipeline.triggerPipelineOnEveryGithubPR(triggerName, ['RS3':true, 'folderFilter':folderFilter])
    windowsPipeline.triggerPipelineOnPush(triggerName, ['RS3':true, 'folderFilter':folderFilter])
}

def linuxPipeline = Pipeline.createPipeline(this, 'linux-pipeline.groovy')

['1.*', '2.0/*', '2.1/*'].each { folderFilter ->
    def triggerName = "Linux ${folderFilter[0..-2]} Build"

    linuxPipeline.triggerPipelineOnEveryGithubPR(triggerName, ['folderFilter':folderFilter])
    linuxPipeline.triggerPipelineOnPush(triggerName, ['folderFilter':folderFilter])
}
