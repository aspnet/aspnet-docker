import org.dotnet.ci.pipelines.Pipeline

def windowsPipeline = Pipeline.createPipeline(this, 'build-pipeline/windows-pipeline.groovy')

[
    '1.*:sac2016',
    '2.0/nanoserver-sac2016/*:sac2016',
    '2.0/nanoserver-1709/*:1709'
].each { platform ->
    def(folderFilter, containerOS) = platform.tokenize(':')
    def triggerName = "Windows ${containerOS} ${folderFilter[0..-3]} Build"

    windowsPipeline.triggerPipelineOnEveryGithubPR(triggerName, [folderFilter:folderFilter, os:containerOS])
    windowsPipeline.triggerPipelineOnPush(triggerName, [folderFilter:folderFilter, os:containerOS])
}

def linuxPipeline = Pipeline.createPipeline(this, 'build-pipeline/linux-pipeline.groovy')

['1.*', '2.0/*'].each { folderFilter ->
    def triggerName = "Linux ${folderFilter[0..-3]} Build"

    linuxPipeline.triggerPipelineOnEveryGithubPR(triggerName, ['folderFilter':folderFilter])
    linuxPipeline.triggerPipelineOnPush(triggerName, ['folderFilter':folderFilter])
}
