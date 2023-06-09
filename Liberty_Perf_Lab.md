# Liberty Performance Lab

- Author: [Kevin Grigorenko](mailto:kevin.grigorenko@us.ibm.com)
- Version: V19 (March 20, 2023)

# Table of Contents

- [Introduction](#introduction)
- [Core Concepts](#core-concepts)
- [Installation](#installation)
    - [With podman](#installing-podman)
    - [With Docker Desktop](#installing-docker-desktop)
- [Starting the lab](#start-the-container)
    - [Start with podman](#start-with-podman)
    - [Start with Docker Desktop](#start-with-docker-desktop)
- [Request Timing](#request-timing)
- [Admin Center](#admin-center)
- [IBM Java and IBM Semeru Runtimes Thread Dumps](#ibm-java-and-ibm-semeru-runtimes-thread-dumps)
- [Garbage Collection](#garbage-collection)
- [Health Center Sampling Profiler](#health-center)
- [HTTP NCSA Access Log](#http-ncsa-access-log)
- [Methodology](#methodology)
- [Appendix](#appendix)
    - [Windows Remote Desktop Client](#windows-remote-desktop-client)

# Introduction

IBM® [WebSphere® Application Server](https://www.ibm.com/cloud/websphere-application-platform) (WAS) is a platform for serving Java™-based applications. WAS comes in two major product forms:

1. [WAS traditional](https://www.ibm.com/docs/en/was-nd/9.0.5?topic=network-deployment-all-operating-systems-version-90) (colloquially named tWAS): Released in 1998 and still fully supported and used by many.

2. [WebSphere Liberty](https://www.ibm.com/docs/en/was-liberty/nd): Released in 2012 and designed for fast startup, composability, and the cloud. The commercial WebSphere Liberty product is built on top of the open source [OpenLiberty](https://github.com/OpenLiberty/open-liberty). The colloquial term 'Liberty' may refer to WebSphere Liberty, OpenLiberty, or both.

WAS traditional and Liberty share some source code but [differ in significant ways](http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/documentation/ChoosingTraditionalWASorLiberty-16.0.0.4.pdf).

## Lab Screenshots

<img src="./media/image2.png" width="1022" height="764" />

<img src="./media/image3.png" width="1024" height="788" />

## Lab

### What's in the lab?

This lab covers the major tools and techniques for performance tuning WebSphere Liberty. This is a subset of the [WebSphere Performance and Troubleshooting Lab](https://github.com/ibm/webspherelab/blob/master/WAS_Troubleshooting_Perf_Lab.md) which also covers WAS traditional.

This lab container image comes with WebSphere Liberty pre-installed so installation and configuration steps are skipped.

The way we are using these container images is to run multiple services in the same container (e.g. VNC, Remote Desktop, WebSphere Liberty, a full GUI server, etc.) and although this approach is [valid and supported](https://docs.docker.com/config/containers/multi-service_container/), it is generally not recommended for real-world container images. For labs that demonstrate how to use WebSphere in containers in production, see [WebSphere Application Server and Docker Tutorials](https://github.com/WASdev/ci.docker.tutorials).

## Operating System

This lab is built on top of Linux (specifically, Fedora Linux, which is the open source foundation of RHEL). The concepts and techniques apply generally to other supported operating systems although [details of other operating systems](https://publib.boulder.ibm.com/httpserv/cookbook/Operating_Systems.html) may vary significantly and are covered elsewhere.

## Java

WebSphere Liberty supports [Java 8, 11, 17, or 19 editions](https://openliberty.io/docs/latest/java-se.html).

This lab uses IBM Java 8. The concepts and techniques apply generally to other Java runtimes although details of other Java runtimes (e.g. [HotSpot](https://publib.boulder.ibm.com/httpserv/cookbook/Java-Java_Virtual_Machines_JVMs-HotSpot_JVM.html)) vary significantly and are covered elsewhere.

The IBM Java virtual machine (named J9) has become largely open sourced into the [Eclipse OpenJ9 project](https://github.com/eclipse/openj9). OpenJ9 ships with OpenJDK through the [IBM Semeru Runtimes offering](https://developer.ibm.com/languages/java/semeru-runtimes/downloads). OpenJDK is [somewhat different](https://publib.boulder.ibm.com/httpserv/cookbook/Java.html#Java-General) than the JDK that IBM Java uses. Note that some IBM Java tooling such as HealthCenter is not yet available in IBM Semeru Runtimes (except on z/OS) which is why we chose IBM Java 8 for this lab; however, generally, more modern versions of Java such as IBM Semeru Runtimes would be recommended.

# Core Concepts

Performance tuning is best done with all layers of the stack in mind. This lab will focus on the layers in bold below:

<img src="./media/image4.png" width="530" height="493" />

# Lab environment

## Installation

The lab image is about 20GB. If you plan to run this in a classroom setting, perform the installation steps beforehand which includes downloading the image.

This lab assumes the installation and use of `podman` or Docker Desktop to run the lab (other container systems may also work but have not been tested). Choose one or the other:

* [Installing `podman`](#installing-podman)
* [Installing Docker Desktop](#installing-docker-desktop)

### Installing podman

If you are using `podman` instead of Docker Desktop, perform the following steps to install `podman` and then perform the [podman post-installation steps](#podman-post-installation-steps). If you are using Docker Desktop, [skip down to Installing Docker Desktop](#installing-docker-desktop).

`podman` installation instructions:

* Windows: <https://podman.io/getting-started/installation#windows>
* macOS: <https://podman.io/getting-started/installation#macos>
* For a Linux host, simply [install](https://publib.boulder.ibm.com/httpserv/cookbook/Operating_Systems-Linux.html#Operating_Systems-Linux-Installing_Programs) `podman`

#### podman post-installation steps

1. On macOS and Windows:
    1. Create the `podman` virtual machine with sufficient memory (preferrably at least 4GB and, ideally, at least 8GB), CPU, and disk. For example (memory is in MB):
       ```
       podman machine init --memory 10240 --cpus 4 --disk-size 100
       ```
    1. Start the `podman` virtual machine:
       ```
       podman machine start
       ```
    1. Switch to a "root" podman connection:
       ```
       podman system connection default podman-machine-default-root
       ```
    1. Run the following command to allow producing core dumps within the container:
       ```
       podman machine ssh "sh -c 'mkdir -p /etc/sysctl.d/; ln -sf /dev/null /etc/sysctl.d/50-coredump.conf && sysctl -w kernel.core_pattern=core'"
       ```
1. Download the image:
   ```
   podman pull quay.io/ibm/webspherelab
   ```
   This command may not show any output for a long time while the download completes.

The following section on Docker Desktop should be skipped since you are using `podman`. The next section for `podman` is [Start with podman](#start-with-podman).

### Installing Docker Desktop

If you are using Docker Desktop instead of `podman`, perform the following steps to install Docker Desktop and then perform the [Docker Desktop post-installation steps](#docker-desktop-post-installation-steps):

* Windows (we recommend using WSL2):
    * Required:
      > * Windows 11 64-bit: Home or Pro version 21H2 or higher, or Enterprise or Education version 21H2 or higher.
      > * Windows 10 64-bit: Home or Pro 21H1 (build 19043) or higher, or Enterprise or Education 20H2 (build 19042) or higher.
    * Download: <https://docs.docker.com/desktop/install/windows-install/>
* macOS ("macOS must be version 11 or newer"):
    * Download: <https://docs.docker.com/desktop/install/mac-install/>
* For a Linux host, simply install and start Docker (e.g. `sudo systemctl start docker`):
    * For an example, see <https://docs.docker.com/engine/install/fedora/>

#### Docker Desktop post-installation steps

1.  Ensure that Docker is started. For example, start Docker Desktop and ensure it is running:\
    \
    macOS:\
    <img src="./media/image148.png" width="295" height="467" />\
    \
    Windows:\
    <img src="./media/image152.png" width="368" height="522" />

3.  Ensure that Docker receives sufficient resources, particularly memory (at least 4GB and, ideally, at least 8GB), CPU, and disk:
    1. macOS:

        1.  Click the Docker Desktop icon and select **Dashboard**

        1.  Click the **Settings** gear icon in the top right, then click **Resources** on the left.

        1.  Configure sufficient memory (preferrably at least 4GB and, ideally, at least 8GB), CPU, and disk.

        1.  Click **Apply & Restart**\
            \
            macOS:\
            <img src="./media/image149.png" width="672" height="720" />

    1. The Windows WSL2 backend defaults to 50% of RAM or 8GB, whichever is less, and the same number of CPUs as the host. This may be overridden with a [`%UserProfile%\.wslconfig` file](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configuration-setting-for-wslconfig) with, for example (preferrably at least 4GB and, ideally, at least 8GB):
       ```
       [wsl2]
       memory=10GB
       processors=4
       ```

4.  Open a terminal or command prompt and download the image:
    ```
    docker pull quay.io/ibm/webspherelab
    ```

## Start the container

Depending on whether you installed `podman` or Docker Desktop, start the container:

* [Start with `podman`](#start-with-podman)
* [Start with Docker Desktop](#start-with-docker-desktop)

### Start with podman

The following section is the start of the lab. If you were only preparing for the lab by installing and downloading the lab before the lab begins, then you may stop at this point until the instructor provides further direction.

If you are using `podman` for this lab instead of Docker Desktop, then perform the following steps. If you are using Docker Desktop, [skip down to Start with Docker Desktop](#start-with-docker-desktop).

1.  Open a terminal or command prompt:\
    \
    macOS:\
    <img src="./media/image11.png" width="588" height="108" />\
    \
    Windows:\
    <img src="./media/image12.png" width="463" height="393" />

1.  Start the lab:
    ```
    podman run --cap-add sys_chroot --rm -p 5901:5901 -p 5902:5902 -p 3390:3389 -p 9080:9080 -p 9443:9443 -it quay.io/ibm/webspherelab
    ```

2.  Wait about 5 minutes until you see the following in the output (if not seen, review any errors):
    
        =========
        = READY =
        =========

3.  VNC or Remote Desktop into the container:

    1.  macOS built-in VNC client:

        1.  Open another tab in the terminal and run:

            1.  **open vnc://localhost:5902**

            2.  Password: **websphere**

    1.  Linux VNC client:

        1.  Open another tab in the terminal and run:

            1.  **vncviewer localhost:5902**
                * You may need to [install](https://publib.boulder.ibm.com/httpserv/cookbook/Operating_Systems-Linux.html#Operating_Systems-Linux-Installing_Programs) `vncviewer` first.
            2.  Password: **websphere**

    1.  Windows 3<sup>rd</sup> party VNC client:

        i.  If you are able to install and use a 3<sup>rd</sup> party VNC client, then connect to **localhost** on port **5902** with password **websphere**.

    1.  Windows Remote Desktop client:

        i.  Windows requires a few steps to make Remote Desktop work with a Docker container. See [Appendix: Windows Remote Desktop Client](#windows-remote-desktop-client) for instructions.

4.  When using VNC, you may change the display resolution from within the container and the VNC client will automatically adapt. For example:\
    \
    <img src="./media/image13.png" width="1160" height="615" />

The following section on Docker Desktop should be skipped since you are using `podman`. The next section for `podman` is [Apache JMeter](#apache-jmeter).

### Start with Docker Desktop

The following section is the start of the lab. If you were only preparing for the lab by installing and downloading the lab before the lab begins, then you may stop at this point until the instructor provides further direction.

If you are using Docker Desktop for this lab instead of `podman`:

1.  Open a terminal or command prompt:\
    \
    macOS:\
    <img src="./media/image11.png" width="588" height="108" />\
    \
    Windows:\
    <img src="./media/image12.png" width="463" height="393" />

2.  Start the lab by starting the Docker container from the command line:
    ```
    docker run --rm -p 5901:5901 -p 5902:5902 -p 3390:3389 -p 9080:9080 -p 9443:9443 -it quay.io/ibm/webspherelab
    ```

3.  Wait about 5 minutes until you see the following in the output (if not seen, review any errors):
    
        =========
        = READY =
        =========

4.  VNC or Remote Desktop into the container:

    1.  macOS built-in VNC client:

        1.  Open another tab in the terminal and run:

            1.  **open vnc://localhost:5902**

            2.  Password: **websphere**

    1.  Linux VNC client:

        1.  Open another tab in the terminal and run:

            1.  **vncviewer localhost:5902**
                * You may need to [install](https://publib.boulder.ibm.com/httpserv/cookbook/Operating_Systems-Linux.html#Operating_Systems-Linux-Installing_Programs) `vncviewer` first.
            2.  Password: **websphere**

    1.  Windows 3<sup>rd</sup> party VNC client:

        i.  If you are able to install and use a 3<sup>rd</sup> party VNC client (there are a few free options online), then connect to **localhost** on port **5902** with password **websphere**.

    1.  Windows Remote Desktop client:

        i.  Windows requires a few steps to make Remote Desktop work with a Docker container. See [Appendix: Windows Remote Desktop Client](#windows-remote-desktop-client) for instructions.

6.  When using VNC, you may change the display resolution from within the container and the VNC client will automatically adapt. For example:\
    \
    <img src="./media/image13.png" width="1160" height="615" />

## Apache Jmeter

[Apache JMeter](https://jmeter.apache.org/) is a free tool that drives artificial, concurrent user load on a website. The tool is pre-installed in the lab image and we\'ll be using it to simulate website traffic to the [DayTrader7 sample application](https://github.com/WASdev/sample.daytrader7) pre-installed in the lab image.

### Start JMeter

1.  Double click on JMeter on the desktop:\
    \
    <img src="./media/image14.png" width="1021" height="791" />

2.  Click **File** → **Open** and select:

    1.  **/opt/daytrader7/jmeter\_files/daytrader7\_liberty.jmx**

3.  By default, the script will execute 4 concurrent users. You may change this if you want (e.g. based on the number of CPUs available):\
    \
    <img src="./media/image15.png" width="677" height="228" />

4.  Click the green run button to start the stress test and click the **Aggregate Report** item to see the real-time results.\
    \
    <img src="./media/image16.png" width="757" height="252" />

5.  It will take some time for the responses to start coming back and for all of the pages to be exercised.

6.  Ensure that the **Error %** value for the **TOTAL** row at the bottom is always 0%.\
    \
    <img src="./media/image17.png" width="1008" height="375" />

    1.  If there are any errors, review the logs:

        1.  **/logs/messages.log**

### Stop JMeter

1.  Stop a JMeter test by clicking the STOP button:

    <img src="./media/image18.png" width="1021" height="278" />

2.  Click the broom button to clear the results in preparation for the next test:

    <img src="./media/image19.png" width="1021" height="278" />

3.  If it asks what to do with the JMeter log files from the previous test, you may just click **Overwrite existing file**:

    <img src="./media/image20.png" width="716" height="140" />

# Mousepad

If you would like to view or edit text files in the container using a GUI tool, you may use a program such as **mousepad**:

<img src="./media/image21.png" width="323" height="442" />

---

# Request Timing

This lab demonstrates how to enable and use WebSphere Liberty's [slow and hung request detection](https://www.ibm.com/docs/en/was-liberty/nd?topic=liberty-slow-hung-request-detection) feature. You can specify a threshold for what the application stakeholders define as an excessively slow web request and Liberty watches requests and prints a stack trace and other details when a request exceeds such a threshold. Note that enabling `requestTiming-1.0` may have a large overhead in high volume environments and ideally its overhead should be measured in a test environment before applying to production; if the overhead is too high, test with request sampling through the [`sampleRate` attribute](https://www.ibm.com/docs/en/was-liberty/nd?topic=configuration-requesttiming).

To detect slow and hung requests, the Liberty `requestTiming-1.0` feature is required in a Liberty server's configuration. In addition to enabling the feature, the feature must be configured with a [`requestTiming`](https://www.ibm.com/docs/en/was-liberty/nd?topic=configuration-requesttiming) element that specifies the thresholds and other configuration. This lab will be using the following:

```
<requestTiming slowRequestThreshold="60s" hungRequestThreshold="180s" sampleRate="1" />
```

The key configuration is the `slowRequestThreshold` which specifies the time after which a request is considered to be "slow" and diagnostics are printed to Liberty logs. In general, this value must be decided with application stakeholders based on service level agreements. Note that if a high volume of requests start to exceed this threshold, there will be some overhead of printing diagnostics to the logs, in which case you can consider increasing the threshold or the `sampleRate`.

The difference between the slow and hung thresholds is that if the hung threshold is exceeded, then Liberty will gather 3 thread dumps, one minute apart for more in-depth diagnostics. This will not be demonstrated in this lab but it is generally advised to configure both thresholds.

## requestTiming Lab

1. Modify `/config/server.xml` (for example, using the `Mousepad` program on the Desktop) to add the following before `</server>` and save the file:
   ```
   <featureManager><feature>requestTiming-1.0</feature></featureManager>
   <requestTiming slowRequestThreshold="60s" hungRequestThreshold="180s" sampleRate="1" />
   ```
2. Execute a request that takes more than one minute by opening a browser to <http://localhost:9080/swat/Sleep?duration=65000>
3. After about a minute and the request completes, review the requestTiming warning in `/logs/messages.log` (for example, using the `Mousepad` program) -- for example:
   ```
   [3/20/22 16:16:52:250 UTC] 0000007b com.ibm.ws.request.timing.manager.SlowRequestManager         W TRAS0112W: Request AAAAPOsEvAG_AAAAAAAAAAA has been running on thread 00000079 for at least 60003.299ms. The following stack trace shows what this thread is currently running.
   
     at java.lang.Thread.sleep(Native Method)
     at java.lang.Thread.sleep(Thread.java:956)
     at com.ibm.Sleep.doSleep(Sleep.java:35)
     at com.ibm.Sleep.doWork(Sleep.java:18)
     at com.ibm.BaseServlet.service(BaseServlet.java:73)
     at javax.servlet.http.HttpServlet.service(HttpServlet.java:790)
     [...]
   
   The following table shows the events that have run during this request.
   
   Duration      Operation
   60008.080ms + websphere.servlet.service | swat | Sleep?duration=65000 
   ```
    1. The warning shows a stack at the time `requestTiming` notices the threshold is breached and it's followed be a tree of components of the request. The plus sign (+) indicates that an operation is still in progress. The indentation level indicates which events requested which other events.
4. Execute a request that takes about three minutes by opening a browser to http://localhost:9080/swat/Sleep?duration=200000
5. After about five minutes, review the requestTiming warning in `/logs/messages.log` -- in addition to the previous warning, multiple thread dumps are produced:
   ```
   [3/20/22 16:22:23:565 UTC] 0000007d com.ibm.ws.kernel.launch.internal.FrameworkManager           A CWWKE0067I: Java dump request received.
   [3/20/22 16:22:23:662 UTC] 0000007d com.ibm.ws.kernel.launch.internal.FrameworkManager           A CWWKE0068I: Java dump created: /opt/ibm/wlp/output/defaultServer/javacore.20220320.162223.17.0001.txt
   ```
    1. Thread dumps [will be captured](https://openliberty.io/docs/latest/slow-hung-request-detection.html#_hung_request_detection), one minute apart, after the threshold is breached.
1. Detailed steps on analyzing thread dumps are covered in a subsequent lab.

In general, it is a good practice to use `requestTiming`, even in production. Configure the thresholds to values that are at the upper end of acceptable times for the users and the business. Configure and test the `sampleRate` to ensure the overhead of `requestTiming` is acceptable in production.

When the requestTiming feature is enabled, the server dump command will include a snapshot of all the event trees for all requests thus giving a very nice and lightweight way to see active requests in the system at a detailed level (including URI, etc.), in a similar way that thread dumps do the same for thread stacks.

# Admin Center

WebSphere Liberty's [Admin Center](https://www.ibm.com/docs/en/was-liberty/base?topic=liberty-administering-using-admin-center) is an optional, web-based administration and monitoring tool for Liberty servers. Admin Center is enabled with the `adminCenter-1.0` feature as well as configuring administrator credentials.

If you are already using another monitoring product, you may skip this Admin Center lab.

For monitoring statistics to be produced and visualized in Admin Center (or published to monitoring products such as [Instana](https://www.ibm.com/docs/en/instana-observability/current?topic=technologies-monitoring-websphere-liberty)), the Liberty `monitor-1.0` feature is required in a Liberty server's configuration. This feature enables the collection of monitoring statistics which can then be consumed by clients such as the Admin Center, Instana, etc. Note that enabling `monitor-1.0` may have an overhead of up to a few percent although this may be minimized by [filtering to specific statistics, if needed](https://www.ibm.com/docs/en/was-liberty/nd?topic=10-multiple-components-monitoring).

## Admin Center Lab

This lab will demonstrate how to enable Admin Center and `monitor-1.0` and visualize statistics for the sample application.

1. Modify `/config/server.xml` (for example, using the `Mousepad` program on the Desktop) to add the following before `</server>` and save the file:
   ```
   <featureManager><feature>adminCenter-1.0</feature><feature>monitor-1.0</feature></featureManager>
   ```
1. Open the browser (for example, using `Applications` in the top left and then `Web Browser`)
1. Navigate to <https://localhost:9443/adminCenter> and accept the self-signed certificate.
1. Log in with the user name `wsadmin` and the password `websphere`.
1. Click on the **Explore** button:\
   <img src="./media/image124.png" width="640" height="308" />
1. Click on the \"Monitor\" button:\
   <img src="./media/image125.png" width="428" height="417" />
1. [Start JMeter](#start-jmeter)
1. Go back to the Admin Center Monitor screen and you will see graphs of various statistics for this server:\
   <img src="./media/monitor1.png" width="815" height="630" />
1. The [default statistics](https://www.ibm.com/docs/en/was-liberty/nd?topic=center-monitoring-metrics-in-admin) are:
    * Used Heap Memory: Java heap usage. Note that most modern garbage collectors are generational meaning that trash tends to accumulate in old regions and is cleaned up less often thus leading to a common sawtooth pattern. In some cases, the rise on such a tooth might look like a leak, but may not be.
    * Loaded Classes: The total number of loaded and unloaded classes.
    * Active JVM Threads: The number of live, total, and peak threads. Note that this shows all threads, not just the Default Executor threads.
    * CPU Usage: Average CPU utilization for the process.
1. Click the pencil button in the top right to edit the displayed statistics:
   
   <img src="media/acserveredit.png" width="100" height="148" />

1. Click the plus buttons to the right of `Thread Pool`, `Connection Pool`, and `Sessions`. Note that it's expected that the `+` button won't turn into a checkbox when you click on `Connection Pool` and `Sessions`; these will become checked after one of the subsequent steps below.
   
   <img src="media/acservereditcheck.png" width="311" height="458" />

1. Close the metrics side bar:
   
   <img src="media/acservereditclose.png" width="311" height="458" />

1. Scroll down to the new statistics boxes. For the `In Use Connections` and `Average Wait Time (ms)` boxes, use the `Select data sources...` dropdown to select `jdbc/TraceDataSource`. Note that if you want to view multiple data sources, it's generally better to create multiple boxes and choose one data source per box instead of checking the `All` box as it's harder to interpret aggregated statistics.
   
   <img src="media/monitor2.png" width="378" height="321" />

1. Scroll down to the `Active Sessions` box and use the `Select sessions...` dropdown to select `default_host/daytrader`. As above, if you want to view sessions for multiple applications, it's generally better to create separate boxes.
   
   <img src="media/monitor3.png" width="418" height="321" />

1. Click the `Save` button at the top right to make the box selections permanent:
   
   <img src="media/acmonitorsave.png" width="234" height="137" />

1. This completes the section on server-level statistics. The available statistics are limited but generally these statistics are the most important for 80% or more of monitoring situations. For more detailed monitoring, use monitoring products such as [Instana](https://www.ibm.com/docs/en/instana-observability/current?topic=technologies-monitoring-websphere-liberty).
1. Next, you will view application-level statistics. Click on `Applications` on the left side:
   
   <img src="media/monitor4.png" width="225" height="222" />

1. Click on the `daytrader` box title:
   
   <img src="media/monitor5.png" width="591" height="364" />

1. Click on the `Monitor` button on the left:
   
   <img src="media/monitor6.png" width="420" height="220" />

1. By default, there are boxes for `Request Count` which is the total number of HTTP requests, and `Average Response Time (ns)` which is the average response time in nanoseconds.
   
   <img src="media/monitor7.png" width="827" height="419" />

1. For each box, click on the dropdown and select `Show Legend` to show the legends:
   
   <img src="media/monitor8.png" width="577" height="304" />

1. As with server-level statistics, available application-level statistics in the Admin Center are limited but generally these statistics are the most important for 80% or more of monitoring situations. For more detailed monitoring, use monitoring products such as [Instana](https://www.ibm.com/docs/en/instana-observability/current?topic=technologies-monitoring-websphere-liberty).

# IBM Java and IBM Semeru Runtimes Thread Dumps

Thread dumps are snapshots of process activity, including the thread stacks that show what each thread is doing. Thread dumps are one of the best places to start to investigate problems. If a lot of threads are in similar stacks, then that behavior might be an issue or a symptom of an issue.

For IBM Java or IBM Semeru Runtimes, a thread dump is also called a javacore or javadump. [HotSpot-based thread dumps](https://publib.boulder.ibm.com/httpserv/cookbook/Troubleshooting-Troubleshooting_Java-Troubleshooting_HotSpot_JVM.html#Troubleshooting-Troubleshooting_HotSpot_JVM-Thread_Dump) are covered elsewhere.

This exercise will demonstrate how to gather and review thread dumps in the free [IBM Thread and Monitor Dump Analyzer (TMDA) tool](https://www.ibm.com/support/pages/ibm-thread-and-monitor-dump-analyzer-java-tmda).

Thread dumps may be gathered in many different ways. This lab will demonstrate both the [IBM performance, hang, and high CPU MustGather](https://www.ibm.com/support/pages/mustgather-performance-hang-or-high-cpu-issues-websphere-application-server-linux) as well as the Liberty [`server dump`](https://www.ibm.com/docs/en/was-liberty/core?topic=line-generating-liberty-server-dump-from-command) tool.

## Thread Dumps Theory

An IBM Java or IBM Semeru Runtimes thread dump is generated in a **javacore\*.txt** file with a snapshot of process activity, including:

- Each Java thread and its stack.
- A list of all Java synchronization monitors, which thread owns each monitor, and which threads are waiting for the lock on a monitor.
- Environment information, including Java command line arguments and operating system ulimits.
- Java heap usage and information about the last few garbage collections.
- Detailed native memory and classloader information.

Thread dumps generally do not contain sensitive information about user requests, but they may contain sensitive information about the application or environment such as host names and environment variables, so they should be treated sensitively. In general, a thread dump is cheap (pauses the JVM for only a few hundred milliseconds), small (generally less than a few MB), and low risk.

## server dump

Liberty offers a [`server dump`](https://www.ibm.com/docs/en/was-liberty/core?topic=line-generating-liberty-server-dump-from-command) utility which gathers useful state about the Liberty process, logs, configuration and, optionally, requests a thread dump.

This lab demonstrates how to gather a `server dump` and review its output.

1. Open a terminal on the lab image; for example, double click on `Xfce Terminal` on the Desktop.
1. Run the following command to start the Liberty server dump:
   ```
   /opt/ibm/wlp/bin/server dump defaultServer --include=thread
   ```
1. Once the command completes, it shows the path to the dump ZIP; for example:
   ```
   Dumping server defaultServer.
   Server defaultServer dump complete in /opt/ibm/wlp/output/defaultServer/defaultServer.dump-23.03.22_14.13.16.zip.
   ```
1. Move the dump ZIP to your current directory:
   ```
   mv /opt/ibm/wlp/output/defaultServer/*dump*zip .
   ```
1. Unzip the dump ZIP:
   ```
   unzip *dump*zip
   ```
1. List the current directory with `ls -l` to find the dump output; in particular, there is a `javacore*txt` file which was taken due to `--include=thread`, Liberty logs under `logs/`, Liberty configuration such as `server.xml`, and Liberty introspections under the `dump_*` subdirectory.
1. The server dump ZIP file is generally what you would send to your development team to review a potential problem, or upload it to an IBM Support case.
1. The next lab will demonstrate how to analyze the `javacore*txt` thread dump files in more detail.

## linperf.sh

IBM WebSphere Support provides a script called **linperf.sh** as part of the document, ["MustGather: Performance, hang, or high CPU issues with WebSphere Application Server on Linux"](https://www.ibm.com/support/pages/mustgather-performance-hang-or-high-cpu-issues-websphere-application-server-linux) (similar scripts exist for other operating systems such as [AIX](https://www.ibm.com/support/pages/mustgather-performance-hang-or-high-cpu-issues-websphere-application-server-aix), [z/OS](https://www.ibm.com/support/pages/mustgather-gathering-data-hang-or-performance-problem-zos), and [Windows](https://www.ibm.com/support/pages/mustgather-performance-hang-or-high-cpu-issues-windows)). This script will be used to gather thread dumps in this lab. Such a script should be pre-installed on all machines where you run Liberty and it should be run when you have performance or hang issues and the resulting files should be uploaded if you open a support case with IBM. This script is complementary to the Liberty `server dump` as the `server dump` also gathers Liberty logs, configuration, and introspections. It's best to run both during an issue.

The linperf.sh script is pre-installed in the lab image at **/opt/linperf/linperf.sh**.

## Thread Dumps Lab

We will gather and review thread dumps:

> Note: You may skip the data collection steps 1-8 and start at step 9 with example data packaged at /opt/webspherelab/supplemental/exampledata/liberty/linperf/

1.  [Start JMeter](#start-jmeter)

2.  Open a terminal on the lab image; for example, double click on `Xfce Terminal` on the Desktop.

3.  First, we'll need to find the PID(s) of Liberty. There are a few ways to do this, and you only need to choose one method:

    1.  Show all processes (**ps -elf**), search for the process using something unique in its command line (**grep defaultServer**), exclude the search command itself (**grep -v grep**), and then select the fourth column (in bold below):

        <pre>
        $ ps -elf | grep defaultServer | grep -v grep
        4 S was       <b>1567</b>     1 99  80   0 - 802601 -     19:26 pts/1    00:03:35 java -javaagent:/opt/ibm/wlp/bin/tools/ws-javaagent.jar -Djava.awt.headless=true -Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/ -jar /opt/ibm/wlp/bin/tools/ws-server.jar defaultServer
        </pre>
        
    1.  Search for the process using something unique in its command line using **pgrep -f**:

        <pre>
        $ pgrep -f defaultServer
        <b>1567</b>
        </pre>

4.  Execute the **linperf.sh** command and pass the PID gathered above (replace 1567 with your PID from the output above):

        $ /opt/linperf/linperf.sh 1567
        Tue Apr 23 19:29:26 UTC 2019 MustGather>> linperf.sh script starting [...]

5.  Wait for 4 minutes for the script to finish before continuing to the next step:

    <pre>
    [...]
    Tue Apr 23 19:33:33 UTC 2019 MustGather&gt;&gt; <b>linperf.sh script complete</b>.
    Tue Apr 23 19:33:33 UTC 2019 MustGather&gt;&gt; Output files are contained within ----&gt;   linperf_RESULTS.tar.gz.   &lt;----
    Tue Apr 23 19:33:33 UTC 2019 MustGather&gt;&gt; <b>The javacores that were created are NOT included in the linperf_RESULTS.tar.gz.</b>
    Tue Apr 23 19:33:33 UTC 2019 MustGather&gt;&gt; Check the &lt;profile_root&gt; for the javacores.
    Tue Apr 23 19:33:33 UTC 2019 MustGather&gt;&gt; Be sure to submit linperf_RESULTS.tar.gz, the javacores, and the server logs as noted in the MustGather.
    </pre>

6.  As mentioned at the end of the script output, the resulting **linperf_RESULTS.tar.gz** does not include the thread dumps. Move them over to the current directory:

        mv /opt/ibm/wlp/output/defaultServer/javacore.* .

7.  [Stop JMeter](#stop-jmeter)

8.  At this point, if you were creating a support case, you would upload **linperf_RESULTS.tar.gz**, **javacore\***, and all the Liberty logs; however, instead, we will analyze the results.

9.  From the desktop, double click on **TMDA**.

10.  Click Open Thread Dumps and select all of the **javacore\*.txt** files using the Shift key. These will be in your home directory (**/home/was**) if you moved them above; otherwise, they're in the default working directory (**/opt/ibm/wlp/output/defaultServer**):\
    \
    <img src="./media/image27.png" width="183" height="95" />\
    \
    <img src="./media/image28.png" width="513" height="339" />\
    <img src="./media/image29.png" width="475" height="335" />

4.  Select a thread dump and click the **Thread Detail** button:\
    \
    <img src="./media/image30.png" width="723" height="178" />

5.  Click on the **Stack Depth** column to sort by thread stack depth in ascending order.

6.  Click on the **Stack Depth** column again to sort again in descending order:\
    \
    <img src="./media/image31.png" width="375" height="178" />

7.  Generally, the threads of interest are those with stack depths greater than \~20. Select any such rows and review the stack on the right (if you don't see any, then close this thread dump and select another from the list):\
    \
    <img src="./media/image32.png" width="1018" height="529" />

    1.  Generally, to understand which code is driving the thread, skip any non-application stack frames. In the above example, the first application stack frame is TradeAction.getQuote.

    2.  Thread dumps are simply snapshots of activity, so just because you capture threads in some stack does not mean there is necessarily a problem. However, if you have a large number of thread dumps, and an application stack frame appears with high frequency, then this may be a problem or an area of optimization. You may send the stack to the developer of that component for further research.

8.  In some cases, you may see that one thread is blocked on another thread. For example:\
    \
    <img src="./media/image33.png" width="1018" height="584" />

    1.  The **Monitor** line shows which monitor this thread is waiting for, and the stack shows the path to the request for the monitor. In this example, the application is trying to commit a database transaction. This lab uses the Apache Derby database engine which is not a very scalable database. In this example, optimizing this bottleneck may not be easy and may require deep Apache Derby expertise.

    2.  You may click on the thread name in the **Blocked by** view to quickly see the thread stack of the other thread that owns the monitor.

    3.  Lock contention is a common cause of performance issues and may manifest with poor performance and low CPU usage.

9.  An alternative way to review lock contention is by selecting a thread dump and clicking **Monitor Detail**:\
    \
    <img src="./media/image34.png" width="720" height="177" />\
    \
    <img src="./media/image35.png" width="1014" height="223" />

    1.  This shows a tree view of the monitor contention which makes it easier to explore the relationships and number of threads contending on monitors. In the above example, **Default Executor-thread-153** owns the monitor and **Default Executor-thread-202** is waiting for the monitor.

10. You may also select multiple thread dumps and click the **Compare Threads** button to see thread movement over time:\
    \
    <img src="./media/image36.png" width="719" height="177" />\
    \
    <img src="./media/image37.png" width="1018" height="585" />

    1.  Each column is a thread dump and shows the state of each thread (if it exists in that thread dump) over time. Generally, you're interested in threads that are runnable (Green Arrow) or blocked or otherwise in the same concerning top stack frame. Click on each cell in that row and review the thread dump on the right. If the thread dump is always in the same stack, this is a potential issue. If the thread stack is changing a lot, then this is usually normal behavior.

    2.  In general, focus on the main application thread pools such as DefaultExecutor, WebContainer, etc.

Next, let's simulate a hung thread situation and analyze the problem with thread dumps:

> Note: You may skip the data collection steps and use example data packaged at /opt/webspherelab/supplemental/exampledata/liberty/threaddump\_deadlock/

1.  Open a browser to: <http://localhost:9080/swat/>

2.  Scroll down and click on Deadlocker:\
    \
    <img src="./media/image38.png" width="1373" height="96" />

3.  Wait until the continuous browser output stops writing new lines of \"Socrates \[\...\]\" which signifies that the threads have become deadlocked and then gather a thread dump of the WAS process by sending it the **SIGQUIT** **(3)** signal. Although the name of the signal includes the word "QUIT", the signal is captured by the JVM, the JVM pauses for a few hundred milliseconds to produce the thread dump, and then the JVM continues. This same command is performed by **linperf.sh**. It is a quick and cheap way to quickly understand what your JVM is doing:

        kill -3 $(pgrep -f defaultServer)

    1.  Note that here we are using a sub-shell to send the output of the pgrep command (which finds the PID of WAS) as the argument for the kill command.

    1.  This can be simplified even further with the **pkill** command which combines **pgrep** functionality:
    
            pkill -3 -f defaultServer

4.  In the TMDA tool, clear the previous list of thread dumps:\
    \
    <img src="./media/image39.png" width="718" height="181" />

5.  Click **File** \> **Open Thread Dumps** and navigate to **/opt/ibm/wlp/output/defaultServer** and select both new thread dumps and click **Open**:\
    \
    <img src="./media/image40.png" width="511" height="338" />

6.  When you select the first thread dump, TMDA will warn you that a deadlock has been detected:\
    \
    <img src="./media/image41.png" width="718" height="226" />

    1.  Deadlocks are not common and mean that there is a bug in the application or product.

7.  Use the same procedure as above to review the **Monitor Details** and **Compare Threads** to find the thread that is stuck. In this example, the **DefaultExecutor** application thread actually spawns threads and waits for them to finish, so the application thread is just in a Thread.join:\
    \
    <img src="./media/image42.png" width="1009" height="182" />

8.  The actual spawned threads are named differently and show the blocking:\
    \
    <img src="./media/image43.png" width="413" height="152" />

Next, let's simulate a thread that is using a lot of CPU:

> Note: You may skip the data collection steps and use example data packaged at /opt/webspherelab/supplemental/exampledata/liberty/threaddump\_infiniteloop/

1.  Go to: <http://localhost:9080/swat/>

2.  Scroll down and click on InfiniteLoop:\
    \
    <img src="./media/image44.png" width="1372" height="87" />

3.  Go to the container terminal and start **top -H** with a 10 second interval:

        top -H -d 10

    <img src="./media/image45.png" width="818" height="193" />

4.  Notice that a single thread is consistently consuming \~100% of a single CPU thread.

5.  Convert the PID to hexadecimal. In the example above, **22129** = **0x5671**.

    1.  In the container, open Galculator:\
        \
        <img src="./media/image46.png" width="325" height="316" />

    1.  Click View \> Scientific Mode:\
        \
        <img src="./media/image47.png" width="334" height="374" />

    1.  Enter the decimal number (in this example, **22129**), and then click on **HEX**:\
        \
        <img src="./media/image48.png" width="720" height="347" />

    1.  The result is **0x5671**:

        <img src="./media/image49.png" width="720" height="347" />

6.  Take a thread dump of the parent process:

        pkill -3 -f defaultServer

7.  Open the most recent thread dump from **/opt/ibm/wlp/output/defaultServer/** in a text editor such as **mousepad**:\
    \
    <img src="./media/image50.png" width="589" height="392" />

8.  Search for the native thread ID in hex (in this example, 0x5671) to find the stack trace consuming the CPU (if captured during the thread dump):\
    \
    <img src="./media/image51.png" width="1023" height="191" />

9.  Finally, kill the server destructively (**kill -9**) because trying to stop it gracefully will not work due to the infinitely looping request:

        pkill -9 -f defaultServer

1. Restart the Liberty server for the next lab:
   ```
   /opt/ibm/wlp/bin/server start defaultServer
   ```

# Garbage Collection

Garbage collection (GC) automatically frees unused objects. Healthy garbage collection is one of the most important aspects of Java programs. The proportion of time spent in garbage collection versus application time should be [less than 10% and ideally less than 1%](https://publib.boulder.ibm.com/httpserv/cookbook/Major_Tools-Garbage_Collection_and_Memory_Visualizer_GCMV.html#Major_Tools-Garbage_Collection_and_Memory_Visualizer_GCMV-Analysis).

This lab will demonstrate how to enable verbose garbage collection in WAS for the sample DayTrader application, exercise the application using Apache JMeter, and review verbose garbage collection data in the free [IBM Garbage Collection and Memory Visualizer (GCMV)](https://www.ibm.com/support/pages/garbage-collection-and-memory-visualizer) tool.

## Garbage Collection Theory

All major Java Virtual Machines (JVMs) are designed to work with a maximum Java heap size. When the Java heap is full (or various sub-heaps), an allocation failure occurs and the garbage collector will run to try to find space. Verbose garbage collection (verbosegc) prints detailed information about each one of these allocation failures.

Always enable verbose garbage collection, including in production (benchmarks show an overhead of less than 1% for [IBM Java](https://publib.boulder.ibm.com/httpserv/cookbook/Java-Java_Virtual_Machines_JVMs-OpenJ9_and_IBM_J9_JVMs.html#Java-Java_Virtual_Machines_JVMs-OpenJ9_and_IBM_J9_JVMs-Garbage_Collection-Verbose_garbage_collection_verbosegc)), using the options to rotate the verbosegc logs. For [IBM Java](http://www.ibm.com/support/knowledgecenter/SSYKE2_8.0.0/com.ibm.java.lnx.80.doc/diag/appendixes/cmdline/xverbosegclog.html) - 5 historical files of roughly 20MB each:

    -Xverbosegclog:verbosegc.%seq.log,5,50000

## Garbage Collection Lab

Add the verbosegc option to the jvm.options file:

> Note: You may skip the data collection steps and use example data packaged at /opt/webspherelab/supplemental/exampledata/liberty/verbosegc\_and\_oom/

1.  [Stop JMeter](#stop-jmeter) if it is started.

1.  WebSphere Liberty:

    1.  Stop the Liberty server.

            /opt/ibm/wlp/bin/server stop defaultServer

    1.  Open a text editor such as mousepad and add the following line to it:

            -Xverbosegclog:logs/verbosegc.%seq.log,5,50000

    1.  Save the file to **/opt/ibm/wlp/usr/servers/defaultServer/jvm.options**\
        \
        <img src="./media/image52.png" width="643" height="398" />

    1.  Start the Liberty server

            /opt/ibm/wlp/bin/server start defaultServer

1.  [Start JMeter](#start-jmeter)

2.  Run the test for about 5 minutes.

3.  [Stop JMeter](#stop-jmeter)

4.  From the desktop, double click on **GCMV**:

5.  Click **File** \> **Load File\...** and select the **verbosegc.001.log** file. For example:\
    \
    <img src="./media/image53.png" width="243" height="105" />

6.  Select **/opt/ibm/wlp/output/defaultServer/logs/verbosegc.001.log**\
    \
    <img src="./media/image54.png" width="645" height="476" />

7.  Once the file is loaded, you will see the default line plot view. It is common to change the **X-axis** to **date** to see absolute timestamps:\
    \
    <img src="./media/image55.png" width="156" height="93" />

8.  Click the **Data Selector** tab in the top left, choose **VGC Pause** and check **Total pause time** to add the total garbage collection pause time plot to the graph:\
    \
    <img src="./media/image56.png" width="260" height="473" />

9.  Do the same as above using **VGC Heap** and check **Used heap (after global collection)**:\
    <img src="./media/image57.png" width="255" height="105" />\
    \
    <img src="./media/image58.png" width="255" height="243" />

10. Observe the heap usage and pause time magnitude and frequency over time. For example:\
    \
    <img src="./media/image59.png" width="704" height="543" />

    1.  This shows that the heap size reaches 145MB and the heap usage (after global collection) reached \~80MB.

11. More importantly, we want to know the proportion of time spent in GC. Click the **Report** tab and review the **Proportion of time spent in garbage collection pauses (%)**:\
    \
    <img src="./media/image60.png" width="654" height="592" />

    1.  If this number is less than 1%, then this is very healthy. If it's less than 5% then it's okay. If it's less than 10%, then there is significant room for improvement. If it's greater than 10%, then this is concerning.

Next, let's simulate a memory issue.

> Note: You may skip the data collection steps and use example data packaged at /opt/webspherelab/supplemental/exampledata/liberty/verbosegc\_and\_oom/

1.  [Stop JMeter](#stop-jmeter) if it is started.

1.  Liberty:

    1.  Stop Liberty:

        /opt/ibm/wlp/bin/server stop defaultServer

    1.  Edit **/opt/ibm/wlp/usr/servers/defaultServer/jvm.options**, add an explicit maximum heap size of 256MB on a new line and save the file:

        `-Xmx256m`

        <img src="./media/image61.png" width="697" height="103" />

    1.  Start Liberty

        /opt/ibm/wlp/bin/server start defaultServer

1.  [Start JMeter](#start-jmeter)

1.  Let the JMeter test run for about 5 minutes.

1.  Do not stop the JMeter test but leave it running as you continue to the next step.

1.  Open your browser to the following page: <http://localhost:9080/swat/AllocateObject?size=1048576&iterations=300&waittime=1000&retainData=true>

    1.  This will allocate three hundred 1MB objects with a delay of 1 second between each allocation, and hold on to all of them to simulate a leak.

    1.  This will take about 5 minutes to run and you can watch your browser output for progress.

    1.  You can run **top -H** while this is running. As memory pressure builds, you'll start to see **GC Slave** threads consuming most of the CPUs instead of application threads (garbage collection also happens on the thread where the allocation failure occurs, so you may also see a single application thread consuming a similar amount of CPU as the GC Slave threads):

        `top -H -p $(pgrep -f defaultServer) -d 5`

        <img src="./media/image68.png" width="847" height="320" />

    1.  At some point, browser output will stop because the JVM has thrown an OutOfMemoryError.

1.  [Stop JMeter](#stop-jmeter)

1.  Forcefully kill the JVM because an OutOfMemoryError does not stop the JVM; it will continue garbage collection thrashing and consume all of your CPU.

            pkill -9 -f defaultServer

1.  Close and re-open the **verbosegc\*log** file in GCMV:\
    \
    <img src="./media/image141.png" width="555" height="539" />

    1.  We can quickly see how the heap usage reaches 256MB and the pause time magnitude and durations increase significantly.

1. Click on the **Report** tab and review the **Proportion of time spent in garbage collection pauses (%)**:\
    \
    <img src="./media/image143.png" width="474" height="43" />

1. 24% seems pretty bad but not terrible and doesn't line up with what we know about what happened. This is because, by default, the GCMV Report tab shows statistics for the entire duration of the verbosegc log file. Since we had run the JMeter test for 5 minutes and it was healthy, the average proportion of time in GC is lower for the whole duration.

1. Click on the **Line plot** tab and zoom in to the area of high pause times by using your mouse button to draw a box around those times:\
    \
    <img src="./media/image144.png" width="564" height="543" />

1. This will zoom the view to that bounding box:\
    \
    <img src="./media/image145.png" width="550" height="536" />

1. However, zooming in is just a visual aid. To change the report statistics, we need to match the X-axis to the period of interest.

1. Hover your mouse over the approximate start and end points of the section of concern (frequent pause time spikes) and note the times of those points (in terms of your selected X Axis type):\
    \
    <img src="./media/image142.png" width="555" height="536" />

1. Enter each of the values in the minimum and maximum input boxes and press **Enter** on your keyboard in each one to apply the value. The tool will show vertical lines with triangles showing the area of the graph that you\'ve cropped to.\
    \
    <img src="./media/image146.png" width="800" height="559" />

1. Click on the **Report** tab at the bottom and observe the proportion of time spent in garbage collection for this period is very high (in this example, \~87%).\
    \
    <img src="./media/image147.png" width="473" height="49" />

1. This means that the application is doing very little work and is very unhealthy. In general, there are a few, non-exclusive ways to resolve this problem:

    1.  Increase the maximum heap size.

    1.  Decrease the object allocation rate of the application.

    1.  Resolve memory leaks through heapdump analysis.

    1.  Decrease the maximum thread pool size.

# Health Center

[IBM Monitoring and Diagnostics for Java - Health Center](https://publib.boulder.ibm.com/httpserv/cookbook/Major_Tools-IBM_Java_Health_Center.html) is free and shipped with IBM Java 8. Among other things, Health Center includes a statistical CPU profiler that samples Java stacks that are using CPU at a very high rate to determine what Java methods are using CPU. Health Center generally has an overhead of less than 1% and is suitable for production use. In recent versions, it may also be enabled dynamically without restarting the JVM.

This lab will demonstrate how to enable Java Health Center, exercise the sample DayTrader application using Apache JMeter, and review the Health Center file in the IBM Java Health Center Client Tool.

## Health Center Theory

The Health Center agent gathers sampled CPU profiling data, along with other information:

-   Classes: Information about classes being loaded

-   Environment: Details of the configuration and system of the monitored application

-   Garbage collection: Information about the Java heap and pause times

-   I/O: Information about I/O activities that take place.

-   Locking: Information about contention on inflated locks

-   Memory: Information about the native memory usage

-   Profiling: Provides a sampling profile of Java methods including call paths

The Health Center agent can be enabled in two ways:

1.  At startup by adding **-Xhealthcenter:level=headless** to the JVM arguments

2.  At runtime, by running **\${IBM\_JAVA}/bin/java -jar \${IBM\_JAVA}/jre/lib/ext/healthcenter.jar ID=\${PID} level=headless**

Note: For both items, you may add the following arguments to limit and roll the total file usage of Health Center data:

<pre>
<b>-Dcom.ibm.java.diagnostics.healthcenter.headless.files.max.size=BYTES</b>
<b>-Dcom.ibm.java.diagnostics.healthcenter.headless.files.to.keep=N</b> (N=0 for unlimited)
</pre>

The key to produce the final Health Center HCD file is that the JVM should be gracefully stopped (there are alternatives to this by packaging the temporary files but this isn't generally recommended).

Consider always enabling [HealthCenter in headless mode](https://publib.boulder.ibm.com/httpserv/cookbook/Major_Tools-IBM_Java_Health_Center.html#Major_Tools-IBM_Java_Health_Center-Gathering_Data) for post-mortem debugging of issues.

## Health Center Lab

> Note: You may skip the data collection steps and use example data packaged at /opt/webspherelab/supplemental/exampledata/liberty/healthcenter/

1.  [Stop JMeter](#stop-jmeter) if it is started.

2.  Add Health Center arguments to the JVM:

    1.  Add the following line to **/opt/ibm/wlp/usr/servers/defaultServer/jvm.options**:

        `-Xhealthcenter:level=headless`

3.  Stop the server:

        /opt/ibm/wlp/bin/server stop defaultServer

4.  Start the server

        /opt/ibm/wlp/bin/server start defaultServer

5.  [Start JMeter](#start-jmeter) and run it for 5 minutes.

6.  [Stop JMeter](#stop-jmeter)

7.  Stop WAS as in step 3 above.

8.  From the desktop, double click on **HealthCenter**.

9.  Click **File \> Load Data\...** (note that it\'s towards the bottom of the **File** menu; **Open File** does not work):\
    \
    <img src="./media/image107.png" width="643" height="656" />

10. Select the **healthcenter\*.hcd** file from **/opt/ibm/wlp/output/defaultServer**:\
    <img src="./media/image108.png" width="784" height="260" />

11. Wait for the data to complete loading:\
    \
    <img src="./media/image109.png" width="962" height="137" />

12. Click on CPU:\
    <img src="./media/image110.png" width="892" height="382" />

13. Review the overall system and Java application CPU usage:\
    <img src="./media/image111.png" width="694" height="498" />

14. Right click anywhere in the graph and change the **X-axis** to **date** (which changes all other views to **date** as well):\
    <img src="./media/image112.png" width="694" height="498" />

    1.  For large Health Center captures, this may take significant time to change and there is no obvious indication when it's complete. The best way to know is when the CPU usage of Health Center drops to a low amount.

15. Click **Data \> Crop data\...**\
    \
    <img src="./media/image113.png" width="495" height="114" />

16. Change the **Start time** and **End time** to match the period of interest. For example, usually you want to exclude the start-up time of the process and only focus on user activity:\
    <img src="./media/image114.png" width="613" height="392" />

17. Click **Window \> Preferences**:\
    <img src="./media/image115.png" width="734" height="599" />

18. Check the **Show package names** box under **Health Center \> Profiling** and press **OK** so that we can see more details in the profiling view:\
    <img src="./media/image116.png" width="648" height="570" />

19. Click on **Method profiling** to review the CPU sampling data:\
    <img src="./media/image117.png" width="309" height="307" />

20. The **Method profiling** view will show CPU samples by method:\
    <img src="./media/image118.png" width="712" height="482" />

21. The **Self (%)** column reports the percent of samples where a method was at the top of the stack. The **Tree (%)** column reports the percent of samples where a method was somewhere else in the stack. Make sure to check that the **Samples** column is at least in the hundreds or thousands; otherwise, the CPU usage is likely not that high or a problem did not occur. The **Self** and **Tree** percentages are a percent of samples, not of total CPU.

22. Any methods over \~1% are worthy of considering how to optimize or to avoid. For example, \~2% of samples were in method 0x2273c68 (for various reasons, some methods may not resolve but you can usually figure things out from the invocation paths). Selecting that row and switching to the **Invocation Paths** view shows the percent of samples leading to those calls:\
    <img src="./media/image119.png" width="712" height="482" />

    1.  In the above example, 63.11% of samples (i.e. of 2.9% of total samples) were invoked by org.apache.derby.impl.sql.conn.GenericLanguageConnectionContext.doCommit.

23. If you sort by **Tree %**, skip the framework methods from Java and WAS, and find the first application method. In this example, about 32% of total samples was consumed by com.ibm.websphere.samples.daytrader.web.TradeAppServlet.performTask and all of the methods it called. The **Called Methods** view may be further reviewed to investigate the details of this usage; in this example, doPortfolio drove most of the CPU samples.\
    \
    <img src="./media/image120.png" width="859" height="482" />

# HTTP NCSA Access Log

The Liberty HTTP access log is optionally enabled with the [httpEndpoint accessLogging element](https://openliberty.io/docs/latest/access-logging.html). When enabled, a separate `access.log` file is produced with an NCSA standardized (i.e. httpd-style) line for each HTTP request, including [items such as the URI and response time](https://openliberty.io/docs/latest/access-logging.html#_http_access_log_format), useful for post-mortem corelation and performance analysis.

## HTTP NCSA Access Log Lab

1. Modify `/config/server.xml` to change the following element:
   ```
   <httpEndpoint id="defaultHttpEndpoint"
              host="*"
              httpPort="9080"
              httpsPort="9443" />
   ```
2. To the following (note that the `<httpEndpoint>` element must no longer be self-closing):
   ```
   <httpEndpoint id="defaultHttpEndpoint"
              host="*"
              httpPort="9080"
              httpsPort="9443">
     <accessLogging filepath="${server.output.dir}/logs/access.log" maxFileSize="250" maxFiles="2" logFormat="%h %i %u %t &quot;%r&quot; %s %b %D %{R}W" />
   </httpEndpoint>
   ```
3. [Start JMeter](#start-jmeter)
4. Run the test for a couple of minutes.
5. [Stop JMeter](#stop-jmeter)
6. Review `/opt/ibm/wlp/output/defaultServer/logs/access.log` to see HTTP responses. For example:
   ```
   127.0.0.1 - Admin1 [20/Mar/2022:16:28:23 +0000] "GET /daytrader/app?action=portfolio HTTP/1.1" 200 12927 397114 390825
   127.0.0.1 - Admin1 [20/Mar/2022:16:28:23 +0000] "GET /daytrader/app?action=quotes&symbol=s%3A6651 HTTP/1.1" 200 7849 528280 526508
   127.0.0.1 - Admin1 [20/Mar/2022:16:28:23 +0000] "GET /daytrader/app?action=quotes&symbol=s%3A9206 HTTP/1.1" 200 7849 528556 526676
   ```
6. The second-to-last number is the response time in microseconds. In the example above, the first response time was 397.114 milliseconds. The last number is the time until the first byte of the response was sent back which may help investigate network slowdowns in front of WebSphere.

There are various scripts and tools available publicly ([example](https://raw.githubusercontent.com/kgibm/problemdetermination/master/scripts/general/ncsa_response_times.awk)) to post-process NCSA-style access logs to create statistics and graphs.

In general, it is a good practice to use `accessLogging`, even in production, if the performance overhead is acceptable.

# Other WebSphere Liberty Features

Consider reviewing other common performance tuning and troubleshooting operations and capabilities:

* Review [performance tuning guidance](https://www.ibm.com/docs/en/was-liberty/nd?topic=tuning-liberty) and the [WebSphere Performance Cookbook](https://publib.boulder.ibm.com/httpserv/cookbook/).
* A key differentiator of WebSphere Liberty is its [auto-tuning main thread pool](https://www.ibm.com/docs/en/was-liberty/nd?topic=tuning-liberty) that dynamically changes the maximum thread pool size to try to maximize throughput. In most cases, this means that an administrator does not need to specify nor tune the main application thread pool. Note that other pools such as [database connection pools](https://www.ibm.com/docs/en/was-liberty/core?topic=liberty-configuring-connection-pooling-database-connections), web service client pools and others do not auto-tune as those are backend resources out of the control of Liberty, so they must still be tuned.
* [MicroProfile Metrics](https://www.ibm.com/docs/en/was-liberty/nd?topic=environment-monitoring-microprofile-metrics) provides the ability to produce the same statistics as `monitor-1.0` but exposed through a Prometheus-style `/metrics` HTTP endpoint for consumption by Prometheus or custom scripts.
* [Distributed tracing](https://www.ibm.com/docs/en/was-liberty/nd?topic=environment-enabling-distributed-tracing) to monitor the flow of JAX-RS web service calls through a web of Liberty processes.
* WebSphere Liberty has a rich set of [configuration capabilites](https://www.ibm.com/docs/en/was-liberty/nd?topic=tools-creating-editing-your-server-environment-files) through XML files and variables (`server.xml`, etc.), Java options files (`jvm.options`), and environment variables (`server.env` or through the process environment). Most WebSphere Liberty configuration changes may be done dynamically, [by default](https://www.ibm.com/docs/en/was-liberty/nd?topic=manually-controlling-dynamic-updates).
* An optional [servlet response cache](https://www.ibm.com/docs/en/was-liberty/nd?topic=features-web-response-cache-10) that takes significant effort to configure but may have a dramatic return on investment in reduced server utilization and improved response times.
* If using collectives:
    * Consider grouping Liberty servers running the same application into [Liberty clusters](https://www.ibm.com/docs/en/was-liberty/nd?topic=clusters-configuring-liberty-server-cluster) for easier management.
    * Consider the [auto scaling features](https://www.ibm.com/docs/en/was-liberty/nd?topic=collectives-setting-up-auto-scaling-liberty) to dynamically scale the number of Liberty servers based on CPU and memory.
    * [Dynamic routing rules](https://www.ibm.com/docs/en/was-liberty/nd?topic=collectives-routing-rules-liberty-dynamic-routing) in a collective may be used to route requests to specific servers, redirect requests, or reject requests. This includes the capability of handling multiple editions of an application and [routing a percentage of requests](https://www.ibm.com/docs/en/was-liberty/nd?topic=collectives-configuring-routing-rules-liberty-dynamic-routing) to certain editions, for example.
    * Consider using [maintenance mode](https://www.ibm.com/docs/en/was-liberty/nd?topic=collectives-maintenance-mode) for clusters during diagnostics or maintenance operations.
    * Consider using [health policies](https://www.ibm.com/docs/en/was-liberty/nd?topic=collectives-configuring-health-management-liberty) to capture diagnostics and perform other operations based on different conditions.
* The most common performance tuning that needs to be done is to change the maximum Java heap size (`-Xmx` or `-XX:MaxRAMPercentage`), the maximum Java nursery size (`-Xmn`), and maximum pool sizes such as database connection pools.
* Flexible diagnostic trace capabilities with the option of using a [binary output format](https://www.ibm.com/docs/en/was-liberty/nd?topic=overview-binary-logging) for reduced overhead.
* Consider integrating the [WebSphere Automation product](https://www.ibm.com/docs/en/ws-automation) that helps with server inventory, security patching, and automatic memory leak detection and diagnosis.
* If running WebSphere Liberty on [IBM Java](https://www.ibm.com/docs/en/sdk-java-technology/8?topic=SSYKE2_8.0.0/welcome/welcome_javasdk_version.htm) or [IBM Semeru Runtimes](https://developer.ibm.com/languages/java/semeru-runtimes/):
    * A [shared class cache](https://www.eclipse.org/openj9/docs/shrc/) to improve startup time.
    * Various [garbage collection policies](https://www.eclipse.org/openj9/docs/gc/) for different workloads.
    * [Method tracing](https://www.eclipse.org/openj9/docs/xtrace/) to take diagnostic actions on method entry or exit, or to time method calls.
    * A [dump engine](https://www.eclipse.org/openj9/docs/xdump/) to gather diagnostics on various events such as large object allocations, thrown or caught exceptions, etc.
    * A [JITServer](https://www.eclipse.org/openj9/docs/jitserver/) to separate Just-In-Time compilation into a separate process and share compiled code across processes.
    * For richer memory analysis, consider enabling and configuring core dumps (e.g. [core and file ulimits](https://publib.boulder.ibm.com/httpserv/cookbook/Operating_Systems.html#core-dumps-and-ulimits), [`kernel.core_pattern` truncation settings](https://publib.boulder.ibm.com/httpserv/cookbook/Troubleshooting-Troubleshooting_Java.html#ensure-core-piping-is-configured-properly-or-disabled-on-linux), etc.) after reviewing the [security](https://publib.boulder.ibm.com/httpserv/cookbook/Operating_Systems.html#core-dump-security-implications), [disk](https://publib.boulder.ibm.com/httpserv/cookbook/Operating_Systems.html#core-dump-disk-implications) and [performance](https://publib.boulder.ibm.com/httpserv/cookbook/Operating_Systems.html#performance-implications-of-non-destructive-core-dumps) risks.
* Gather basic operating system metrics such as CPU, memory, disk, and network utilization, saturation, and errors.
* Gather operating system logs and watch for warnings and errors.
* Monitor for common network issues such as TCP retransmissions.
* Monitor the web server's access and error logs for warnings and errors.
* Monitor the web server's utilization with tools such as [mod_mpmstats](https://publib.boulder.ibm.com/httpserv/ihsdiag/ihs_performance.html) and [mod_status](https://publib.boulder.ibm.com/httpserv/manual24/mod/mod_status.html).
* For newer applications, advanced capabilities for [fault tolerance](https://www.ibm.com/docs/en/was-liberty/nd?topic=liberty-improving-microservice-resilience-in) such as automatic retries, circuit breakers, fallbacks, and bulkheads. In addition, [health checks](https://www.ibm.com/docs/en/was-liberty/nd?topic=liberty-performing-microprofile-health-checks) may be enabled using readiness and liveness probes.
* When running in a container environment such as OpenShift:
    * Consider deploying applications using the [WebSphere Liberty Operator](https://www.ibm.com/docs/en/was-liberty/base?topic=operator-websphere-liberty-overview) and use capabilities such as the [WebSphereLibertyTrace](https://www.ibm.com/docs/en/was-liberty/base?topic=resources-webspherelibertytrace-custom-resource) and [WebSphereLibertyDump](https://www.ibm.com/docs/en/was-liberty/base?topic=resources-webspherelibertydump-custom-resource) custom resources.
    * [Enable JSON logging](https://github.com/WASdev/ci.docker#logging) and publish native logs of pods to [OpenShift centralized logging](https://docs.openshift.com/container-platform/latest/logging/cluster-logging-deploying.html) using, most commonly, [EFK](https://github.com/OpenLiberty/open-liberty-operator/blob/main/doc/observability-deployment.adoc#how-to-analyze-open-liberty-logs), and then search logs in the Kibana log viewer. Optionally install [sample Kibana dashboards](https://github.com/WASdev/sample.dashboards) that summarize application log events and statistics.
    * Consider enabling [application monitoring integrated with and Grafana](https://www.ibm.com/docs/en/was-liberty/nd?topic=operator-monitoring-applications-red-hat-openshift).
    * If you have `cluster-admin` permissions, use the [MustGather: Performance, hang, or high CPU issues with WebSphere Application Server on Linux on Containers](https://www.ibm.com/support/pages/mustgather-performance-hang-or-high-cpu-issues-websphere-application-server-linux-containers) during performance, hang, and high-CPU issues.
* You may connect the [JConsole monitoring tool](https://docs.oracle.com/javase/8/docs/technotes/guides/management/jconsole.html) built into Java and access Liberty enabled with the `monitor-1.0` feature through the [localConnector-1.0](https://www.ibm.com/docs/en/was-liberty/core?topic=jmx-configuring-local-connection-liberty) and/or [restConnector-2.0](https://www.ibm.com/docs/en/was-liberty/core?topic=jmx-configuring-secure-connection-liberty) features; however, note that JConsole has connection complexities and limited capabilities and Admin Center is often enough for basic statistics visualization.

# Methodology

The following optional sections review general methodology topics.

## The Scientific Method

1.  Observe and measure evidence of the problem. For example: \"Users are receiving HTTP 500 errors when visiting the website.\"

2.  Create prioritized hypotheses about the causes of the problem. For example: \"I found exceptions in the logs. I hypothesize that the exceptions are creating the HTTP 500 errors.\"

3.  Research ways to test the hypotheses using experiments. For example: \"I searched the documentation and previous problem reports and the exceptions may be caused by a default setting configuration. I predict that changing this setting will resolve the problem if this hypothesis is true.\"

4.  Run experiments to test hypotheses. For example: \"Please change this setting and see if the user errors are resolved.\"

5.  Observe and measure experimental evidence. If the problem is not resolved, repeat the steps above; otherwise, create a theory about the cause of the problem.

## Organizing an Investigation

Keep track of a summary of the situation, a list of problems, hypotheses, and experiments/tests. Use numbered items so that people can easily reference things in phone calls or emails. The summary should be restricted to a single sentence for problems, resolution criteria, statuses, and next steps. Any details are in the subsequent tables. The summary is a difficult skill to learn, so try to constrain yourself to a single (short!) sentence. For example:

### Summary

1.  Problems: 1) Average website response time of 5000ms and 2) website error rate \> 10%.

2.  Resolution criteria: 1) Average response time of 300ms and 2) error rate of \<= 1%.

3.  Statuses: 1) Reduced average response time to 2000ms and 2) error rate to 5%.

4.  Next steps: 1) Investigate database response times and 2) gather diagnostic trace.

### Problems

| \#  | Problem                                  | Case \#     | Status                                                          | Next Steps                                         |
| :-: | ---------------------------------------- | ----------- | --------------------------------------------------------------- | ------------------------------------- |
| 1   | Average response time greater than 300ms | TS001234567 | Reduced average response time to 2000ms by increasing heap size | Investigate database response times               |
| 2   | Website error rate greater than 1%       | TS001234568 | Reduced website error rate to 5% by fixing an application bug.  | Run diagnostic trace for remaining errors |

### Hypotheses for Problem 1

| \#  | Hypothesis                                                                   | Evidence                                                       | Status                                                                                     |
| :-: | ---------------------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| 1   | High proportion of time in garbage collection leading to reduced performance | Verbosegc showed proportion of time in GC of 20%                  | Increased Java maximum heap size to -Xmx1g and proportion of time in GC went down to 5% |
| 2   | Slow database response times                                                 | Thread stacks showed many threads waiting on the database | Gather database re-sponse times                                                         |

### Hypotheses for Problem 2

| \#  | Hypothesis                                                            | Evidence                                                                       | Status                                                                 |
| :-: | --------------------------------------------------------------------- | ---------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| 1 | NullPointerException in com.application.foo is causing errors           | NullPointerExceptions in the logs correlate with HTTP 500 response codes | Application fixed the NullPointerException and error rates were halved |
| 2 | ConcurrentModificationException in com.websphere.bar is causing errors  | ConcurrentModificationExceptions correlate with HTTP 500 response codes | Gather WAS diagnostic trace capturing some exceptions                  |

### Experiments/Tests

| \#  | Experiment/Test               | Start                   | End                     | Environment        | Changes                       | Results                                              |
| :-: | ----------------------------- | ----------------------- | ----------------------- | ------------------ | ----------------------------- | ---------------------------------------------------- |
| 1 | Baseline                        | 2019-01-01 09:00:00 UTC | 2019-01-01 17:00:00 UTC | Production server1 | None                          | Average response time 5000ms; Website error rate 10% |
| 2 | Reproduce in a test environment | 2019-01-02 11:00:00 UTC | 2019-01-01 12:00:00 UTC | Test server1       | None                          | Average response time 8000ms; Website error rate 15% |
| 3 | Test problem 1 - hypothesis 1   | 2019-01-03 12:30:00 UTC | 2019-01-01 14:00:00 UTC | Test server1       | Increase Java heap size to 1g | Average response time 4000ms; Website error rate 15% |
| 4 | Test problem 1 - hypothesis 1   | 2019-01-04 09:00:00 UTC | 2019-01-01 17:00:00 UTC | Production server1 | Increase Java heap size to 1g | Average response time 2000ms; Website error rate 10% |

## General Performance Tuning Tips

1. Performance tuning is usually about focusing on a few key variables. We will highlight the most common tuning knobs that can often improve the speed of the average application by 200% or more relative to the default configuration. The first step, however, should be to use and be guided by the tools and methodologies. Gather data, analyze it and create hypotheses: then test your hypotheses. Rinse and repeat. As Donald Knuth says: \"Programmers waste enormous amounts of time thinking about, or worrying about, the speed of noncritical parts of their programs, and these attempts at efficiency actually have a strong negative impact when debugging and maintenance are considered. We should forget about small efficiencies, say about 97% of the time \[...\]. Yet we should not pass up our opportunities in that critical 3%. A good programmer will not be lulled into complacency by such reasoning, he will be wise to look carefully at the critical code; but only after that code has been identified. It is often a mistake to make a priori judgments about what parts of a program are really critical, since the universal experience of programmers who have been using measurement tools has been that their intuitive guesses fail.\" (Donald Knuth, Structured Programming with go to Statements, Stanford University, 1974, Association for Computing Machinery)

2. There is a seemingly daunting number of tuning knobs. Unless you are trying to squeeze out every last drop of performance, we do not recommend a close study of every tuning option.

3. In general, we advocate a bottom-up approach. For example, with a typical WebSphere Application Server application, start with the operating system, then Java, then WAS, then the application, etc. Ideally, investigate these at the same time. The main goal of a performance tuning exercise is to iteratively determine the bottleneck restricting response times and throughput. For example, investigate operating system CPU and memory usage, followed by Java garbage collection usage and/or thread dumps/sampling profilers, followed by WAS PMI, etc.

4. One of the most difficult aspects of performance tuning is understanding whether or not the architecture of the system, or even the test itself, is valid and/or optimal.

5. Meticulously describe and track the problem, each test and its results.

6. Use basic statistics (minimums, maximums, averages, medians, and standard deviations) instead of spot observations.

7. When benchmarking, use a repeatable test that accurately models production behavior, and avoid short term benchmarks which may not have time to warm up.

8. Take the time to automate as much as possible: not just the testing itself, but also data gathering and analysis. This will help you iterate and test more hypotheses.

9. Make sure you are using the latest version of every product because there are often performance or tooling improvements available.

10. When researching problems, you can either analyze or isolate them. Analyzing means taking particular symptoms and generating hypotheses on how to change those symptoms. Isolating means eliminating issues singly until you\'ve discovered important facts. In general, we have found through experience that analysis is preferable to isolation.

11. Review the full end-to-end architecture. Certain internal or external products, devices, content delivery networks, etc. may artificially limit throughput (e.g. Denial of Service protection), periodically mark services down (e.g. network load balancers, WAS plugin, etc.), or become saturated themselves (e.g. CPU on load balancers, etc.).

### Liberty Performance Tuning Recipe

Review the [common tuning of Liberty and underlying components](https://publib.boulder.ibm.com/httpserv/cookbook/Recipes-WAS_Liberty_Recipes.html) recipe in the IBM WebSphere Performance Tuning Cookbook.

# Appendix

## Stopping the container

The `podman run` or `docker run` command in this lab does not use the `-d` (daemon) flag which means that it runs in the foreground. To stop such a container, use one of the following methods:

1. Hold down the `Control/Ctrl` key on your keyboard and press `C` in the terminal window where the `run` command is running.
1. In a separate terminal window, find the container ID with `podman ps` or `docker ps` command and then run `podman stop $ID` or `docker stop $ID`.

If you add `-d` to `podman run` or `docker run`, then to view the standard out logs, find the container ID with `podman ps` or `docker ps` and then run `podman logs $ID` or `docker logs $ID`. To stop, use `podman stop $ID` or `docker stop $ID`.

## Remote terminal into the container

In a separate command prompt or terminal window, execute one of the following commands depending on whether you're using `podman` or Docker Desktop:

* `podman exec -u was -it $(podman ps -q) bash`
* `docker exec -u was -it $(podman ps -q) bash`

##  Windows Remote Desktop Client

Windows requires [extra steps to configure remote desktop to connect to a container](https://social.msdn.microsoft.com/Forums/en-US/872129e4-07a5-48c3-86f7-996854e7a920/how-to-connect-via-rdp-to-container?forum=windowscontainers):

1. Open **PowerShell** as Administrator:\
   \
   <img src="./media/image132.png" width="451" height="645" />

1. Run **ipconfig** and copy the **IPv4** address of the **WSL** adapter. For example, **172.24.0.1**:\
   \
   <img src="./media/image154.png" width="543" height="133" />

1. Run the following command in **PowerShell**:
   
   `New-NetFirewallRule -Name "myContainerRDP" -DisplayName "RDP Port for connecting to Container" -Protocol TCP -LocalPort @(3390) -Action Allow`

1. Run **Remote Desktop**\
   \
   <img src="./media/image134.png" width="462" height="709" />

1. Enter the WSL IP address (for example, 172.24.0.1) followed by :3390 as **Computer** and click **Connect**:\
   \
   <img src="./media/image156.png" width="542" height="311" />

1. You\'ll see a certificate warning because of the name mismatch. Click **Yes** to connect:\
   \
   <img src="./media/image155.png" width="522" height="577" />

1. Type username = **was** and password = **websphere**\
   \
   <img src="./media/image158.png" width="881" height="1015" />

1. You should now be remote desktop'ed into the container:\
   \
   <img src="./media/image157.png" width="1024" height="576" />

1. Notes:
    1. In some cases, only the **Remote Desktop Connection** application worked, and [**not** **Remote Desktop**](https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/remote-desktop-app-compare):\
       \
       <img src="./media/image139.png" width="343" height="224" />
    1. Microsoft [requires](https://social.msdn.microsoft.com/Forums/en-US/872129e4-07a5-48c3-86f7-996854e7a920/how-to-connect-via-rdp-to-container?forum=windowscontainers) the above steps and the use of port 3390 instead of directly connecting to 3389.

##  Changing Java

There are many different versions and types of Java in the image. To list them, run:

```
$ alternatives --display java | grep "^/"
/usr/lib/jvm/java-11-openjdk-11.0.14.1.1-5.fc35.x86_64/bin/java - family java-11-openjdk.x86_64 priority 11001421
/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.322.b06-6.fc35.x86_64/jre/bin/java - family java-1.8.0-openjdk.x86_64 priority 1
/opt/ibm/java/bin/java - family ibmjava priority 99999999
/opt/openjdk8_hotspot/jdk/bin/java - family openjdk priority 89999999
/opt/openjdk11_hotspot/jdk/bin/java - family openjdk priority 89999999
/opt/openjdk17_hotspot/jdk/bin/java - family openjdk priority 89999999
/opt/openjdk8_ibm/jdk/bin/java - family openjdk priority 89999999
/opt/openjdk11_ibm/jdk/bin/java - family openjdk priority 89999999
/opt/openjdk17_ibm/jdk/bin/java - family openjdk priority 89999999
```

To change the Java that is on the path, run the following command and enter the number of the Java that you wish to change to and press Enter. The directory name tells you the type of Java; for example, OpenJ9 or HotSpot. The directory name also tells you the version of Java (for example, openjdk17 is Java 17).

```
$ sudo alternatives --config java
sudo: unable to send audit message: Operation not permitted

There are 9 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
   1           java-11-openjdk.x86_64 (/usr/lib/jvm/java-11-openjdk-11.0.14.1.1-5.fc35.x86_64/bin/java)
   2           java-1.8.0-openjdk.x86_64 (/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.322.b06-6.fc35.x86_64/jre/bin/java)
*+ 3           ibmjava (/opt/ibm/java/bin/java)
   4           openjdk (/opt/openjdk8_hotspot/jdk/bin/java)
   5           openjdk (/opt/openjdk11_hotspot/jdk/bin/java)
   6           openjdk (/opt/openjdk17_hotspot/jdk/bin/java)
   7           openjdk (/opt/openjdk8_ibm/jdk/bin/java)
   8           openjdk (/opt/openjdk11_ibm/jdk/bin/java)
   9           openjdk (/opt/openjdk17_ibm/jdk/bin/java)

Enter to keep the current selection[+], or type selection number: 9
$ java -version
openjdk version "17.0.2" 2022-01-18
IBM Semeru Runtime Open Edition 17.0.2.0 (build 17.0.2+8)
Eclipse OpenJ9 VM 17.0.2.0 (build openj9-0.30.0, JRE 17 Linux amd64-64-Bit Compressed References 20220128_115 (JIT enabled, AOT enabled)
OpenJ9   - 9dccbe076
OMR      - dac962a28
JCL      - 64cd399ca28 based on jdk-17.0.2+8)
```

The `alternatives` command has the concept of groups of commands so when you change Java using the method above, other commands like **jar**, **javac**, etc. also change.

Any currently running Java programs will need to be restarted if you want them to use the different version of Java (WAS traditional is an exception because it uses a bundled version of Java).

## Common Issues

### VNC and the clipboard

The clipboard may not be shared when using VNC. There are two workarounds:

1. From within the VNC session, open the PDF of the lab from the desktop and use that instead. Then you can copy/paste within the lab.
2. For command line steps, start a new command prompt or terminal and execute one of the following commands depending on whether you're using `podman` or Docker Desktop:
    * `podman exec -u was -it $(podman ps -q) bash`
    * `docker exec -u was -it $(podman ps -q) bash`

### Cannot login after screen locked

This is a known issue that will be fixed on the next build of the lab. Until then, the workaround is:

1. Start a new command prompt or terminal and execute one of the following commands depending on whether you're using `podman` or Docker Desktop:
    * `podman exec -u root -it $(podman ps -q) bash`
    * `docker exec -u root -it $(podman ps -q) bash`
2. Then execute the following command:
   ```
   sed -i '1 i\auth sufficient pam_succeed_if.so user = was' /etc/pam.d/xfce4-screensaver
   ```
3. Try unlocking the screen again.

##  Acknowledgments

Thank you to those that helped build and test this lab:

-   Hiroko Takamiya
-   Andrea Pichler
-   Kazuma Tanabe
-   Shinichi Kako

For the full lab, see <https://github.com/IBM/webspherelab/blob/master/WAS_Troubleshooting_Perf_Lab.md>
