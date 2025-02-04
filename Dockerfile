FROM ghcr.io/epicgames/unreal-engine:dev-4.27 as builder

# Clone the source code for the example Unreal project from github
RUN git clone --progress --depth=1 <YOUR_PROJECT_GITHUB_REPO>  /tmp/<YOUR_PROJECT_NAME> && mv /tmp/<YOUR_PROJECT_NAME> /tmp/project

# Package the example Unreal project
RUN /home/ue4/UnrealEngine/Engine/Build/BatchFiles/RunUAT.sh BuildCookRun \
	-clientconfig=Development -serverconfig=Development \
	-project=/tmp/project/<YOUR_PROJECT_NAME>.uproject \
	-utf8output -nodebuginfo -allmaps -noP4 -cook -build -stage -prereqs -pak -archive \
	-archivedirectory=/tmp/project/dist \
	-platform=Linux

# Copy the packaged project into the Pixel Streaming runtime image
FROM ghcr.io/epicgames/unreal-engine:runtime-pixel-streaming
COPY --from=builder --chown=ue4:ue4 /tmp/project/dist/LinuxNoEditor /home/ue4/project


# Set the project as the container's entrypoint
ENTRYPOINT ["/home/ue4/project/<YOUR_PROJECT_NAME>.sh", "-RenderOffscreen", "-RenderOffscreen", "-AllowPixelStreamingCommands" ,"-PixelStreamingHideCursor" ,"-PixelStreamingWebRTCMaxFps=30", "-PixelStreamingWebRTCDisableReceiveAudio","-FullStdOutLogOutput", "-ForceRes", "-ResX=1920", "-ResY=1080"]
