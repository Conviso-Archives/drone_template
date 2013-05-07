require 'libxml'

include LibXML

module Parse
  module SAX
    class Tool
      def parse_file(xml_file)

        File.unlink(xml_file + ".new") if (File.exists?(xml_file + ".new"))

        #HACK to make the XML tolerate HTML Encode
        fd_reader = File.open(xml_file)
        fd_writer = File.open(xml_file + ".new", 'a')
        
        until(fd_reader.eof?)
          line = fd_reader.readline
          line.gsub!('&', '[AMP]')
          fd_writer.write(line)
        end
        fd_writer.flush
        fd_writer.close

        parser = XML::SaxParser.file(xml_file + ".new")
        parser.callbacks = ToolSAXCallback.new()
        parser.parse
        File.unlink(xml_file + ".new") #HACK to make the XML tolerate HTML Encode
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
        @issues.each do |i|
          i[:affected_component] = "URL: #{i[:variations].first[0]}\nElemento: #{i[:elem]}\nMetodo: #{i[:method]}\nVariavel: #{i[:var]}\nPadrao injetado: #{i[:variations].first[1]}"
        end
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

        if element == 'reference'
          @issue[:reference] = @issue[:reference].to_s + "#{attributes['name']} - #{attributes['url']}\n"
        end
        
        if element =~ /^(name|description|url|severity|_hash|cwe|remedy_guidance|remedy_code|cwe_url|elem|method|var)$/i
          @in_sub_element = true
          @current = element
        end

        if element == 'variations'
          @issue[:variations] = []
        end
        
        if element  == 'variation'
          @in_variation = true
          @variation = []
        end
        
        if @in_variation && element =~ /^(url|injected)$/
          @in_sub_variation = true
          @current = element
        end
        
        if element =~ /^(delta_time|start_datetime|title)$/i
          @in_header_element = true
          @current = element
        end
      end

      def on_characters(chars)
        if @in_issue && @in_sub_element
          #HACK to make the XML tolerate HTML Encode
          @issue[@current.to_sym] = chars.to_s.gsub('[AMP]', '&')
        end
        
        if @in_issue && @in_sub_variation
          @variation << chars.to_s
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

        if element  == 'variation'
          @in_variation = false
          @issue[:variations] << @variation
        end
        
        if @in_variation && element =~ /^(url|injected)$/
          @in_sub_variation = false
        end

        if element =~ /^(name|description|url|severity|_hash|cwe|remedy_guidance|remedy_code|cwe_url|elem|method|var)$/i
          @in_sub_element = false
        end
        
        if element =~ /^(delta_time|start_datetime|title)$/i
          @in_header_element = false
        end
      end

    end
  end
end

