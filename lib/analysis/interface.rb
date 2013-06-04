module Analysis
  class Interface
    attr_accessor :config, :debug
    def initialize (config = nil, debug = nil)
      @config = config
      @debug = debug
    end

    def bulk_analyse(issues = [])
      begin
        raise AnalyseException, "[#{self.class}] Parameter should be an Array" unless (issues.instance_of?(Array))
        return analyse(issues)
      rescue => e
        raise AnalyseException, "[#{self.class}] Error during a bulk analysis"
      end
    end

    def individual_analyse(issue = nil)
      begin
        raise AnalyseException, "[#{self.class}] Parameter should be a Hash" unless (issue.instance_of?(Hash))
        return analyse(issue)
      rescue => e
        raise AnalyseException, "[#{self.class}] Error during an individual analysis"
      end
    end
    
    def analyse(element = nil)
      raise raise AnalyseException, "analyse() method should be implemented"
    end
  end
  
  class AnalyseException < Exception
  end
end