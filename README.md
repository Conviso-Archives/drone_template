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

  - a parser for the output of the tool; For instance, if the tool produces big XMLs use a SAX approach otherwise a DOM approach. This parser should generate a structure according [Issue Internal Format](#issue-internal-format);
    - [lib/parse/sax/tool.rb](lib/parse/sax/tool.rb) or [lib/parse/dom/tool.rb](lib/parse/dom/tool.rb)
  - a XML generator which generates the [Conviso Standard XML](#conviso-standard-xml);
    - [lib/parse/writer/conviso.rb](lib/parse/writer/conviso.rb)
  - a [configuration file](drone-configuration-file) setuped for the current tool;
    - [config.yml.default](config.yml.default)
  - a XMPP module which estabilish the communication with the _Importer_;
    - [lib/communication/xmpp.rb](lib/communication/xmpp.rb)
  - a nottification module which print notifications, warnings and errors in file or in the default output. This module can also be setuped to email the system operator;
    - [lib/output/debug.rb](lib/output/debug.rb) 


## Issue Internal Format

As said before, every drone parse an output format and generates an structure in memory. This structure should follow a standard in order the Drone can understand every field inside an _issue_. The structure should be composed *at least* by the following fields:

```ruby
standard_internal_format = {
:tool_name => "Tool Name",
:duration => "32421", # Time amound in seconds
:start_time => "32421312312", # Unix TimeStamp
:issues=>[
{:url=>"http://www.test.com/", 
 :name=>"Blind SQL Injection", 
 :description=>"Description for Blind SQL Injection", 
 :cwe=>"89", 
 :cwe_url=>"http://cwe.mitre.org/data/definitions/89.html", 
 :severity=>"High", 
 :remedy_guidance=>"",   
 :_hash=>"9ea60ac56efec967be775c046261de10b4b5440beffdcd0ec52fe2e30305d19d",
 :reference=>"http://www.owasp.org/index.php/Blind_SQL_Injection", 
 :affected_component=>"URL: http://www.test.com/portada/\nElemento: cookie\nMetodo: GET"
}, {
  # ... Other Issue
},
{ 
  # ... Other Issue
}],
}


```

In order to take advantage of all analysis modules produced along the history of Drones your parse should produce the Issue Internal Format as output.

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

## Analysis Modules

Each Drone can have severals analysis modules. Analysis modules are plugins which perform some action over issues collected by the drone before send to the Importer. There are two categories for analysis modules: 

 - individual analysis: Analyse each issue isolated from the others. Perform changes at the field of each issue. Return "nil" in case the analysis determine that the issue should be deleted.
 - bulk analysis: Analyse all issues found inside a specific input file. This kind of analysis is mainly used for performing correlation analysis. 

All analysis plugins should be installed inside the [Analysis Directory](lib/analysis) and in order to be loaded by the Drone have to be compliant with some standards: 

 - Module name: "SOMETHING_analysis.rb" (e.g. "blacklist_analysis" or "replace_analysis")
 - All plugins expect receive a issue or a set of issues which each issue use the [Issue Internal Format](#issue-internal-format)
 - If a individual analysis plugin returns a empty hash ("{}") the current analysed issue will be ignored by the Drone.
 - All Analysis modules should extend the "[Analysis Interface](lib/analysis/interface.rb)"

An individual analysis module should have the following pattern: 

```ruby
require File.join(File.dirname(__FILE__), 'interface')

module Analysis
  class AnalysisName < Analysis::Interface
    def analyse (issue = nil)
    	# Do some action with the issue, like change its title
    	issue[:name] = 'new title'
    	return issue # return the modified issue
    end
  end
end
```

An bulk analisys module should have the following pattern:

```ruby
require File.join(File.dirname(__FILE__), 'interface')

module Analysis
  class AnalysisName < Analysis::Interface
    def bulk_analyse (issues = [])
    	# Do some action with the issues, like insert a counter in the begin of each title
    	new_issues = issues.collect {|i| i[:name] = "[#{issues.index(i)}] #{i[:name]}"}
    	return new_issues # Return a list of modified issues
    end
  end
end
```

Observe that all plugins should have an "analyse" or a "bulk_analyse" method which receives a issue or a list of issues respectively.

Each analysis module has a specific session inside the configuration file named with its name. For instance the "blacklist_analysis" module has the follow configuration:

```yaml

analysis:
  blacklist:
    - ISSUE_NAME_HASH
    - ISSUE_NAME_HASH

```
For more details see the [Default Configuration File](config.yml.default) as an example.


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




