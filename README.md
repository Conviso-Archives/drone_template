Drone Template
=================

This project aims help developers to create, test and deploy a new Drone (Agent). We will generically describe _step-by-step_ how use our _mock test Drone_ as a template for implementing a functional Drone. Please, feel confortable to contact [me](mailto:malvares@conviso.com.br) in case of any question about this project.

## What is a Drone?

A Drone is a [Software Agent](http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller). In our context, of testing software applications, drones aim to automate repetitive work executed by human security analysts like: scanning, monitoring and/or attack software application systems. Our phylosophy is that **human analysts have to spent time thinking** ... **let machines do the hard work ;)**.

## Drone Objectives

A Drone has five main objectives:
  - Collect output of a specific tool (XML, CSV, HTML, TXT ...);
  - Parse this output to a structure in memory;
  - Analyse vulnerabilities found in this structure;
  - Generate a XML according the [Conviso Standard XML](#conviso-standard-xml);
  - Send the generated [Conviso Standard XML](#conviso-standard-xml) to the [Importer](#conviso-framework-architecture).

## Conviso Framework Architecture

```
-------------------------------------------
|              CSC-WEB               |  X |
--------------------------------------    |
|              DATABASE              |  M |
--------------------------------------    |
|              IMPORTER              |  P |
--------------------------------------    |
|               DRONES               |  P |
-------------------------------------------
```
The _CSC-WEB_ component is the WEB interface responsible for display a consolidate view of the information inputed by analysts and Drones like _projects_, _issues_, _evidences_, _reports_ and _charts_. The _Importer_ is responsible for connecting all Drones (from all clients and projects) to the database. All information automatically collected and processed by a Drones should be sent to the _Importer_. _Drones_ are agents responsible for collecting and pre-processing from specific data sources and scopes ( _e.g._ network, computational system or host). Finaly we have our communication layer which uses the [Extensible Messaging and Presence Protocol](http://en.wikipedia.org/wiki/XMPP) (XMPP) for safely exchange messages between Drones and Importer.

Importer expects messages containing data using the [Conviso Standard XML](#conviso-standard-xml) as a protocol. This standard represents information about _Issues_ to be imported.


## Conviso Standard XML

All messages sent by Drones to the Importer have to be formated according the Conviso Standard XML protocol. This Standard specifies how a issue is represented inside the Conviso Framework. This means that all Drones has to _transform_ the Tool output on this format in order to stabilish a valid communicaton with the Importer.

Each message can hold a XML containing one or more vulnerabilities to be imported inside a specific project (specified by the *PROJECT_ID* tag). 
```
<scan>

  <header>
    <tool>[TOOL_NAME]</tool>
    <project>[PROJECT_ID]</project>
    <timestamp>[EXECUTION_TIMESTAMP]</timestamp>
    <duration>[DURATION_TIME]</duration>
  </header>

  <vulnerabilities>
    <vulnerability id="1">
      <title>[ISSUE_TITLE]</title>
      <description>[ISSUE_DESCRIPTION]</description>
      <hash>[ISSUE_ID]</hash>

      <optional>
        <impact>[FROM_1_TO_3]</impact>
	      <exploitability>[FROM_1_TO_3]</exploitability>
	      <reproduction>[TEXT_ABOUT_REPRODUCTION]</reproduction>
	      <control>[TEXT_ABOUT_CONTROL]</control>
	      <affected_component>[TEXT_ABOUT_AFFECTED_COMPONENT]</affected_component>
	      <reference>[TEXT_ABOUT_REFERENCES]</reference>
	      <template_id>[TEMPLATE_ID_AS_WE_CAN_FIND_IN_CSC_WEB]</template_id>
      </optional>
    </vulnerability>
  </vulnerabilities>

</scan>
```


## Drone Components

All Drones are composed by four main basic components:

  - a parser for the output of the tool; For instance, if the tool produces big XMLs use a SAX approach ([parser SAX for the tool output format](blob/master/lib/parse/sax/tool.rb)) otherwise you can use a DOM approach ([parser DOM for the tool output format](blob/master/lib/parse/dom/tool.rb));
  - a configuration file setuped 

## Drone Configuration File



