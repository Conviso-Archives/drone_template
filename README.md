Drone Template
=================================================

This project aims help developers to create, test and deploy a new Drone (Agent).


[I] What is a Drone?

A Drone is a software agent (1). In our context, of testing software applications, our drones aim to automate the repetitive work before executed by a human analyst like: scanning, monitoring and/or attack software application systems.

[II] Drone Objectives

A Drone has three main objectives:
  - Collect results output of specific tool;
  - Parse this output to a structure in memory;
  - Analyse the vulnerabilities found in this structure;
  - Generate a XML according the Conviso Standard XML [IV];
  - Send the generated Conviso Standard XML to the Importer [III].

[III] Conviso Framework Architecture

```
-------------------------------------------
|                CSC                 |  X |
--------------------------------------    |
|              DATABASE              |  M |
--------------------------------------    |
|              IMPORTER              |  P |
--------------------------------------    |
|               DRONES               |  P |
-------------------------------------------
```

[IV] Conviso Standard XML

[V] Drone Components

[VI] Drone Configuration File



References


(1) http://en.wikipedia.org/wiki/Software_agent

