require 'rexml/document'

# http://www.germane-software.com/software/rexml/docs/tutorial.html

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
