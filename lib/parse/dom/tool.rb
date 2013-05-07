require 'rexml/document'

module Parse
  module DOM
    class Tool
      def parse_file(xml_file)
        struct = nil
        begin
	        fd=File.new(xml_file)
	        doc = REXML::Document.new fd
	        $rows=doc.root
	        struct = __extract_xml()
	      rescue Exception => e
	        raise e
        end
        return struct
      end
     
     
      private
      # TODO: Refatorar esse metodo
      def __extract_xml()
        begin
          output = {}
          output[:issues] = []
          duration=$rows.elements['//system/delta_time'].text
          toolname=$rows.elements['//title'].text
          start=$rows.elements['//start_datetime'].text

          path="//arachni_report/issues/issue"
          output[:issues] = $rows.elements.collect(path) do |row|  
            {
              :name => row.elements['name'].text.to_s,
              :url =>  row.elements['url'].text.to_s,
              :description => row.elements['description'].text.to_s,
              :reference => row.elements['references'].elements.collect {|e| "#{e.attributes['name']} - #{e.attributes['url']}" }.join("\n"),
              :severity => row.elements['severity'].text.to_s,
              :_hash => row.elements['_hash'].text.to_s,
              :cwe => row.elements['cwe'].nil? ? '' : row.elements['cwe'].text.to_s,
              :remedy_guidance => row.elements['remedy_guidance'].nil? ? '' : row.elements['remedy_guidance'].text.to_s,
              :remedy_code => row.elements['remedy_code'].nil? ? '' : row.elements['remedy_code'].text.to_s,
              :cwe_url => row.elements['cwe_url'].nil? ? '' : row.elements['cwe_url'].text.to_s
            }
          end
          output[:duration]=duration
          output[:start_datetime]=start
          output[:toolname]=toolname
          # eliminando repetidos
          output[:issues].uniq!
        rescue Exception => e
          raise Exception.new 'XML with invalid format'
        end 
        return output
      end
      
    end
  end
end
