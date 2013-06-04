require 'base64'
require 'builder'

module Parse
  module Writer
    class Conviso
      def self.build_xml(issue, config)
        xml = Builder::XmlMarkup.new( :ident => 2)
        xml.instruct! :xml, :encoding => 'UTF-8'

        xml.scan do |s|
          s.header do |h|
            h.tool config['tool_name']
            h.project config['project_id']
            h.timestamp Time.now
          end

          s.vulnerabilities do |vs|
            vs.vulnerability do |v|
              v.hash issue[:_hash]
              v.title Base64.encode64(issue[:name].to_s)
              v.description Base64.encode64("#{issue[:url]} \n\n #{issue[:description]}")
              v.optional do |vo|
                vo.affected_component Base64.encode64(issue[:affected_component].to_s)
                vo.control Base64.encode64("#{issue[:remedy_guidance]} \n #{issue[:remedy_code]}")
                vo.reference Base64.encode64(issue[:reference].to_s)
                vo.reproduction Base64.encode64("#{issue[:cwe]} - #{issue[:cwe_url]}")
                vo.exploitability issue[:severity].to_s.downcase
                vo.template_id issue[:template_id].to_s.downcase
              end # optional
            end # vulnerability
          end # vulnerabilities
        end # scan

      end

    end
  end
end
