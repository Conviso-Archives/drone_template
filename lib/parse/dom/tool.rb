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
require 'rexml/document'


module Parse
  module DOM
    class Tool
      def parse_file(xml_file)
        struct = nil
        begin
	        struct = __extract_xml(xml_file)
        rescue Exception => e
          raise Exception.new 'XML with invalid format'
        end
        return struct
      end
     
     
      private
      def __extract_xml(xml_file)
        doc = REXML::Document.new File.new(xml_file)
        output = {}
        output[:issues] = []
        duration=doc.elements['//system/delta_time'].text

        toolname=doc.elements['//title'].text
        start=doc.elements['//system/start_datetime'].text

        path="//report/issues/issue"
        output[:issues] = doc.elements.collect(path) do |issue|  
          {
            :name => issue.elements['name'].text.to_s,
            :url =>  issue.elements['url'].text.to_s,
            :description => issue.elements['description'].text.to_s,
            :reference => issue.elements['url'].text.to_s,
            :severity => issue.elements['severity'].text.to_s,
            :_hash => issue.elements['_hash'].text.to_s,
            :cwe => issue.elements['cwe'].text.to_s,
            :cwe_url => issue.elements['cwe_url'].nil? ? '' : issue.elements['cwe_url'].text.to_s
          }
        end
        output[:duration]=duration
        output[:start_datetime]=start
        output[:toolname]=toolname

        # eliminando repetidos
        output[:issues].uniq!
        
        return output
      end
      
    end
  end
end
