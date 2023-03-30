# Details

## Installation Highlights

* [Fedora x64](https://hub.docker.com/_/fedora/)
* [WebSphere Liberty](https://hub.docker.com/_/websphere-liberty)
* [WAS traditional Base](https://hub.docker.com/r/ibmcom/websphere-traditional)
* [IBM Java 8](https://hub.docker.com/_/ibmjava)
* [IBM HTTP Server](https://www.ibm.com/docs/en/ibm-http-server/9.0.5)
* [OpenLDAP](https://www.openldap.org/)
* [DayTrader7 on WebSphere Liberty connected to OpenLDAP](https://github.com/WASdev/sample.daytrader7)
* [DayTrader7 on WAS traditional connected to OpenLDAP](https://github.com/WASdev/sample.daytrader7)
* [IBM Garbage Collection Memory Visualizer (GCMV)](https://www.ibm.com/support/pages/garbage-collection-and-memory-visualizer)
* [Eclipse Memory Analyzer Tool (MAT)](https://www.ibm.com/support/pages/eclipse-memory-analyzer-tool-dtfj-and-ibm-extensions)
* [IBM Java Health Center (HC)](https://www.ibm.com/support/pages/health-center-client)
* [NMONVisualizer](https://nmonvisualizer.github.io/nmonvisualizer/)
* [IBM Runtime Diagnostic Code Injection (Java Surgery)](https://www.ibm.com/support/pages/ibm-runtime-diagnostic-code-injection-java-platform-java-surgery)
* [Request Metrics Analyzer Next](https://github.com/kgibm/request-metrics-analyzer-next)
* [IBM Thread and Monitor Dump Analyzer (TMDA)](https://www.ibm.com/support/pages/ibm-thread-and-monitor-dump-analyzer-java-tmda)
* [IBM HeapAnalyzer (HA)](https://www.ibm.com/support/pages/ibm-heapanalyzer)
* [IBM Pattern Modeling and Analysis Tool for Java Garbage Collector (PMAT)](https://www.ibm.com/support/pages/ibm-pattern-modeling-and-analysis-tool-java-garbage-collector-pmat)
* [IBM Trace and Request Analyzer for WAS (TRA)](https://www.ibm.com/support/pages/ibm-trace-and-request-analyzer-websphere-application-server)
* [IBM ClassLoader Analyzer](https://www.ibm.com/support/pages/ibm-classloader-analyzer)
* [Eclipse IDE for Enterprise Java and Web Developers](https://www.eclipse.org/downloads/)
  * [IBM Liberty Developer Tools](https://marketplace.eclipse.org/content/ibm-liberty-developer-tools)
* [Firefox](https://www.mozilla.org/en-US/firefox/)
* [LibreOffice](https://www.libreoffice.org/)
* [Wireshark](https://www.wireshark.org/)
* [Apache JMeter](https://jmeter.apache.org/)
* [OpenJDK 8](https://openjdk.java.net/)
* [Eclipse Mission Control](https://adoptium.net/jmc)
* [IBM Semeru (V8, V11, V17)](https://developer.ibm.com/languages/java/semeru-runtimes/downloads)
* [Eclipse Temurin (V8, V11, V17)](https://adoptium.net/)
* [Liberty Bikes](https://github.com/OpenLiberty/liberty-bikes)
* [TrapIt.ear](https://www.ibm.com/support/pages/websphere-application-server-log-watcher-using-trapitear-watch-websphere-application-server-events)
* [swat.ear](https://github.com/kgibm/problemdetermination)
* [WebSphere Application Server Configuration Comparison Tool](https://www.ibm.com/support/pages/websphere-application-server-configuration-comparison-tool)
* [WAS Data Mining](https://github.com/kgibm/was_data_mining/)
* [WebSphere Performance Cookbook](https://publib.boulder.ibm.com/httpserv/cookbook/)
* [MariaDB](https://mariadb.org/)
* [Apache Derby](https://db.apache.org/derby/)
* [IBM Channel Framework Analyzer](https://www.ibm.com/support/pages/ibm-channel-framework-analyzer)
* [IBM Web Server Plug-in Analyzer for WebSphere Application Server (WSPA)](https://www.ibm.com/support/pages/ibm-web-server-plug-analyzer-websphere-application-server-wspa)
* [Connection and Configuration Verification Tool for SSL/TLS](https://www.ibm.com/support/pages/connection-and-configuration-verification-tool-ssltls)
* [WebSphere Application Server Configuration Visualizer](https://www.ibm.com/support/pages/websphere-application-server-configuration-visualizer)
* [Problem Diagnostics Lab Toolkit](https://www.ibm.com/support/pages/problem-diagnostics-lab-toolkit)
* [Performance Tuning Toolkit](https://www.ibm.com/support/pages/websphere-application-server-performance-tuning-toolkit)
* [SIB Explorer](https://www.ibm.com/support/pages/service-integration-bus-explorer)
* [SIB Performance](https://www.ibm.com/support/pages/service-integration-bus-performance)
* [IBM Database Connection Pool Analyzer for IBM WebSphere Application Server](https://www.ibm.com/support/pages/ibm-database-connection-pool-analyzer-ibm-websphere-application-server)
* [Eclipse MAT Source](https://wiki.eclipse.org/MemoryAnalyzer/Contributor_Reference)
* [IBM Service Integration Bus Destination Handler](https://www.ibm.com/support/pages/ibm-service-integration-bus-destination-handler-version-11)

## Known Limitations

* Audio is not configured. In theory, it should be possible by configuring the host and `run` commands for audio passthrough and starting pulseaudio in the container with `pulseaudio -D`.

## Development

### Building

1. Prepare:
    1. macOS: Install the following and then open a new terminal window.
       ```
       brew install pandoc
       brew install --cask mactex
       ```
1. Delete existing images:
   ```
   podman stop --all
   podman system prune --all --force
   podman rmi --all
   ```
1. Use the root podman connection:
   ```
   podman system connection default podman-machine-default-root
   ```
1. Update version number, date and revision history in `WAS_Troubleshooting_Perf_Lab.md`
1. Update version number, date and revision history in `Liberty_Perf_Lab.md`
1. Update version numbers in the `echo`s at the bottom of `Containerfile`
1. Generate lab PDF (yes, this is before building the final image):
   ```
   sed 's/<img src="\(.*\)" width.*\/>/![](\1)/g' WAS_Troubleshooting_Perf_Lab.md > WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   pandoc --pdf-engine=xelatex -V geometry:margin=1in -s -o WAS_Troubleshooting_Perf_Lab.pdf --metadata title="WebSphere Application Server Troubleshooting and Performance Lab" WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   rm WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   ```
1. Generate Liberty lab PDF:
   ```
   sed 's/<img src="\(.*\)" width.*\/>/![](\1)/g' Liberty_Perf_Lab.md > Liberty_Perf_Lab_imagesconverted.md
   pandoc --pdf-engine=xelatex -V geometry:margin=1in -s -o Liberty_Perf_Lab.pdf --metadata title="Liberty Performance Lab" Liberty_Perf_Lab_imagesconverted.md
   rm Liberty_Perf_Lab_imagesconverted.md
   ```
1. If needed, update Liberty build in `MAVEN_LIBERTY_VERSION` in `fedorawasdebug/Containerfile`
1. `git` add, commit, and push.
1. Remove any previous IHS zips
1. Click the first "Download Fix Pack..." link at <https://www.ibm.com/support/pages/fix-list-ibm-http-server-version-90> and follow through the "IBM HTTP Server archive file for 64-bit Linux, x86" link to download `*IHS-ARCHIVE*zip`
1. `podman manifest create quay.io/ibm/webspherelab:latest`
    1. If there is an error, instead run:
        1. `podman manifest inspect quay.io/ibm/webspherelab | jq '.manifests[].digest' | tr '\n' ' ' | sed 's/"//g'`
        1. For each digest, run `podman manifest remove $DIGEST quay.io/ibm/webspherelab`
1. `podman build --platform linux/amd64 --manifest quay.io/ibm/webspherelab:latest .`
1. Double check the manifest:
   ```
   podman manifest inspect quay.io/ibm/webspherelab
   ```
1. Run the image:
   ```
   podman run --rm -p 5901:5901 -p 5902:5902 -p 3390:3389 -p 9080:9080 -p 9443:9443 -it quay.io/ibm/webspherelab
   ```
1. Test the image (password `websphere`):
    * macOS:
      ```
      open vnc://localhost:5902
      ```
1. `git commit -am "VXX: New version with ..."`
1. `git push`
1. `podman login quay.io`
1. `podman images`
1. Tag the image with the version:
   ```
   podman tag quay.io/ibm/webspherelab quay.io/ibm/webspherelab:VXX
   ```
1. Push all the VXX images:
   ```
   podman push quay.io/ibm/webspherelab:VXX
   ```
1. Push the latest tags:
   ```
   podman push quay.io/ibm/webspherelab:latest
   ```
1. ```
   git tag VXX
   ```
1. ```
   git push --tags
   ```
1. Delete old images from <https://quay.io/repository/ibm/webspherelab?tab=tags>
