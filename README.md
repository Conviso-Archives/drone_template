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

All Drones are composed by five main basic components:

  - a parser for the output of the tool; For instance, if the tool produces big XMLs use a SAX approach otherwise a DOM approach;
    - [lib/parse/sax/tool.rb](lib/parse/sax/tool.rb) or [lib/parse/dom/tool.rb](lib/parse/dom/tool.rb)
  - a XML generator which generates the [Conviso Standard XML](#conviso-standard-xml);
    - [lib/parse/writer/conviso.rb](lib/parse/writer/conviso.rb)
  - a [configuration file](drone-configuration-file) setuped for the current tool;
    - [config.yml.default](config.yml.default)
  - a XMPP module which estabilish the communication with the _Importer_;
    - [lib/communication/xmpp.rb](lib/communication/xmpp.rb)
  - a nottification module which print notifications, warnings and errors in file or in the default output. This module can also be setuped to email the system operator;
    - [lib/output/debug.rb](lib/output/debug.rb) 



## Drone Configuration File

```
tool_name: [TOOL_NAME]

# EX: log/tool.log
log_file: [LOG_FILE_PATH]

sources:
- project_id: [CSC_PROJECT_ID]
  input_directory: [OUTPUT_XML_PATH_FOR_THIS_SCOPE]
- project_id: [CSC_PROJECT_ID]
  input_directory: [OUTPUT_XML_PATH_FOR_THIS_SCOPE]

xmpp:
  username: [TOOL_CLIENT]@bus.conviso.com.br
  password: TOOL_XMPP_PASSWORD
  importer_address: [IMPORTER_ADDRESS]

# ENABLE DRONE NOTIFICATION SYSTEM
# smtp:
#   operator:
#     name: [OPERATOR_NAME]
#     email: [OPERATOR_EMAIL]

# DEFAULT DRONE PLUGIN CONFIGURATION
analysis:
  blacklist: # BLACKLIST A SPECIFIC ISSUE
    - ISSUE_NAME_MD5_HASH
  replace: # REPLACE ANY STRING INSIDE AN ISSUE
    patternXXX: none
    patternYYY: patternYYY_replacement
  template: # ASSOCIATE AN ISSUE TO A CSC TEMPLATE
    ISSUE_NAME_MD5_HASH: CSC_TEMPLATE_ID
    85af276f187188339e0dad777ef75670: 5
    2f3e8bdde5d7d6e742e87050c35ce778: 33
    e0ac625068f4e7ec7a3252628b7b999a: 37
    da68290d890bd3d8336c9256b8c8d920: 36
```

Each Drone has to have its own XMPP credential. For instance, a Drone inside a client called *Lhebs* should have a credential similar to: *tool_lhebs@bus.conviso.com.br* and a password. This credential should be provided upon request. The Importer address should also be provided. De default Importer address is *importer@conviso.com.br*.

If our hypothetical Client *Lhebs* has a project called *LHB_00001* we should configure a source entry to *- project_id: LHB_00001*. The tag *input_directory* should especify the directory which contains the output file for the analysed tool, for instance: *- input_directory: input/tool/*.


## Testing - Validator

Every new Drone before be deployed should be exhaustively tested. For this purpose a project called *Validator* was created. The Validator can be used to test a Drone without insert any information inside the database.

In order to use the validator the [Configuration File](#configuration-file) should be setuped to point to the Validator address instead the importer address.

```
...
xmpp:
  username: [TOOL_CLIENT]@bus.conviso.com.br
  password: TOOL_XMPP_PASSWORD
  importer_address: validator@bus.conviso.com.br
...
```

The validator will receive the XML generated by the Drone e return a "[OK]" response in case the XML is compatible with the [Conviso Standard XML](#conviso-standard-xml). Otherwise he will return a message expain what is wrong with the XML.
 
The example below show us the use of the Validator for testing the "Drone_Template" project.

```
Jarvis:drone_template mabj$ cat config.yml | grep validator
  importer_address: validator@bus.conviso.com.br
  
Jarvis:drone_template mabj$ ruby drone_tool.rb 
[I 2013-5-13 7:48] Loading analysis module:  [./lib/analysis/aggregation_analysis.rb]
[I 2013-5-13 7:48] Loading analysis module:  [./lib/analysis/blacklist_analysis.rb]
[I 2013-5-13 7:48] Loading analysis module:  [./lib/analysis/replace_analysis.rb]
[I 2013-5-13 7:48] Loading analysis module:  [./lib/analysis/template_analysis.rb]
[I 2013-5-13 7:48] Starting  Drone ...
[I 2013-5-13 7:48] Pooling input directory ...
[I 2013-5-13 7:48] #1 files were found.
[I 2013-5-13 7:48] Parsing xml file [input/TOOL_00001/tool_output.xml].
[I 2013-5-13 7:48] Sending message ...
[I 2013-5-13 7:48] VALIDATOR - THIS MESSAGE IS VALID
[I 2013-5-13 7:48] Sending message ...
[I 2013-5-13 7:48] VALIDATOR - THIS MESSAGE IS VALID
```




