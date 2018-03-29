import org.dotnet.ci.pipelines.Pipeline

def windowsPipeline = Pipeline.createPipeline(this, 'build-pipeline/windows-pipeline.groovy')

// Images that can only build on RS1, not RS3
['1.*', '2.0/nanoserver-sac2016/*'].each { folderFilter ->
    def triggerName = "Windows SAC2016 ${folderFilter[0..-3]} Build"

    windowsPipeline.triggerPipelineOnEveryGithubPR(triggerName, ['folderFilter':folderFilter])
    windowsPipeline.triggerPipelineOnPush(triggerName, ['folderFilter':folderFilter])
}

// Images that can only build on RS3, not RS1
def rs3TriggerName = "Windows 1709 2.0/nanoserver-1709 Build"
windowsPipeline.triggerPipelineOnEveryGithubPR(rs3TriggerName, ['RS3':true, 'folderFilter':'2.0/nanoserver-1709/*'])
windowsPipeline.triggerPipelineOnPush(rs3TriggerName, ['RS3':true, 'folderFilter':'2.0/nanoserver-1709/*'])

def linuxPipeline = Pipeline.createPipeline(this, 'build-pipeline/linux-pipeline.groovy')

['1.*', '2.0/*'].each { folderFilter ->
    def triggerName = "Linux ${folderFilter[0..-3]} Build"

    linuxPipeline.triggerPipelineOnEveryGithubPR(triggerName, ['folderFilter':folderFilter])
    linuxPipeline.triggerPipelineOnPush(triggerName, ['folderFilter':folderFilter])
}
