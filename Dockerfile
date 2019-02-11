FROM mcr.microsoft.com/windows/servercore:latest AS download

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN curl.exe -Lo agent.msi http://packages.treasuredata.com.s3.amazonaws.com/3/windows/td-agent-3.3.0-1-x64.msi ; \
    start-process msiexec.exe -Wait -ArgumentList '/i C:\agent.msi /qn /norestart /L*v C:\log';

FROM mcr.microsoft.com/windows/servercore:latest

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=download /opt /opt

RUN $newPath = ('C:\opt\td-agent\embedded\bin;{1}' -f $env:GOPATH, $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
