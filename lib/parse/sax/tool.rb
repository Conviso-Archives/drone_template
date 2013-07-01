#
# Copyright 2013 by Marcos Alvares (malvares@conviso.com.br)
#
# This file is part of the Drone Template project.
# Drone Template is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
require 'libxml'

include LibXML

module Parse
  module SAX
    class Tool
      def parse_file(xml_file)
        parser = XML::SaxParser.file(xml_file)
        parser.callbacks = ToolSAXCallback.new()
        parser.parse
        return parser.callbacks.struct
      end
    end

    class ToolSAXCallback
      include XML::SaxParser::Callbacks
      
      attr_reader :struct
      def on_start_document
        @issue = {}
        @header = {}
        @issues = []
        @current = ''
      end

      def on_end_document
        @issues.uniq!
        @struct = {}
        @struct[:issues] = @issues
        @struct[:duration] = @header[:delta_time]
        @struct[:start_datetime] = @header[:start_datetime]
        @struct[:toolname] = @header[:name]
      end

      def on_start_element_ns(element, attributes, prefix, uri, namespaces)
        if element == 'issue'
          @in_issue = true
          @issue = {}
        end
        
        if @in_issue && element =~ /^(name|description|url|severity|_hash|cwe|cwe_url|elem)$/i
          @in_sub_element = true
          @current = element
        end
        
        if element =~ /^(delta_time|start_datetime|title)$/i
          @in_header_element = true
          @current = element
        end
      end

      def on_characters(chars)
        if @in_issue && @in_sub_element
          @issue[@current.to_sym] = chars.to_s
        end
                
        if @in_header_element
          @header[@current.to_sym] = chars.to_s
        end
      end
      
      def on_end_element(element)
        if element == 'issue'
          @in_issue = false
          @issues << @issue unless @issue.empty?
        end

        if element =~ /^(name|description|url|severity|_hash|cwe|cwe_url|elem)$/i
          @in_sub_element = false
        end
        
        if element =~ /^(delta_time|start_datetime|title)$/i
          @in_header_element = false
        end
      end

    end
  end
end

