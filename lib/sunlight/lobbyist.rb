module Sunlight
  class Filing < SunlightObject
    attr_accessor :filing_id, :filing_period, :filing_date, :filing_amount,
                  :filing_year, :filing_type, :filing_pdf, :client_senate_id,
                  :client_name, :client_country, :client_state,
                  :client_ppb_country, :client_ppb_state, :client_description,
                  :client_contact_firstname, :client_contact_middlename,
                  :client_contact_lastname, :client_contact_suffix,
                  :registrant_senate_id, :registrant_name, :registrant_address,
                  :registrant_description, :registrant_country,
                  :registrant_ppb_country, :lobbyists, :issues

    # Takes in a hash where the keys are strings (the format passed in by the JSON parser)
    #
    def initialize(params)
      params.each do |key, value|    
        instance_variable_set("@#{key}", value) if Filing.instance_methods.include? key
      end
    end

    #
    # Get a filing based on filing ID.
    #
    # See the API documentation:
    #
    # http://wiki.sunlightlabs.com/index.php/Lobbyists.getFiling
    #
    # Returns:
    #
    # A Filing matching the given ID or nil if one wasn't found.
    #
    # Usage:
    #
    # sunlight = Filing.get("29D4D19E-CB7D-46D2-99F0-27FF15901A4C")
    #
    def self.get(id)
      url = construct_url("lobbyists.getFiling", :id => id)

      if (response = get_json_data(url))
        if (f = response["response"]["filing"])
          filing = Filing.new(f)
          filing.lobbyists = filing.lobbyists.map do |lobbyist|
            Lobbyist.new(lobbyist["lobbyist"])
          end
          filing.issues = filing.issues.map do |issue|
            Issue.new(issue["issue"])
          end
          filing
        else
          nil
        end
      else
        nil
      end
    end

    #
    # Search the filing database. At least one of client_name or
    # registrant_name must be provided, along with an optional year.
    #
    # See the API documentation:
    #
    # http://wiki.sunlightlabs.com/index.php/Lobbyists.getFilingList
    #
    # Returns:
    #
    # An array of Filing objects that match the conditions
    #
    # Usage:
    #
    # sunlight = Filing.all_where(:client_name => "SUNLIGHT FOUNDATION")
    #
    def self.all_where(params)
      if params[:client_name].nil? and params[:registrant_name].nil?
        nil
      else
        url = construct_url("lobbyists.getFilingList", params)
        
        if (response = get_json_data(url))
          filings = []
          
          response["response"]["filings"].each do |result|
            filing = Filing.new(result["filing"])

            filing.lobbyists = filing.lobbyists.map do |lobbyist|
              Lobbyist.new(lobbyist["lobbyist"])
            end
            filing.issues = filing.issues.map do |issue|
              Issue.new(issue["issue"])
            end

            filings << filing
          end
          
          if filings.empty?
            nil
          else
            filings
          end
        else
          nil
        end
      end # if params
    end # def self.all_where
  end # class Filing
  
  class Issue < SunlightObject
    attr_accessor :code, :specific_issue

    # Takes in a hash where the keys are strings (the format passed in by the JSON parser)
    #
    def initialize(params)
      params.each do |key, value|    
        instance_variable_set("@#{key}", value) if Issue.instance_methods.include? key
      end
    end
  end
  
  class Lobbyist < SunlightObject
    attr_accessor :firstname, :middlename, :lastname, :suffix,
                  :official_position, :filings, :fuzzy_score
    
    # Takes in a hash where the keys are strings (the format passed in by the JSON parser)
    #
    def initialize(params)
      params.each do |key, value|    
        instance_variable_set("@#{key}", value) if Lobbyist.instance_methods.include? key
      end
    end

    #
    # Fuzzy name searching of lobbyists. Returns possible matching Lobbyists
    # along with a confidence score. Confidence scores below 0.8
    # mean the lobbyist should not be used.
    #
    # See the API documentation:
    #
    # http://wiki.sunlightlabs.com/index.php/Lobbyists.search
    #
    # Returns:
    #
    # An array of Lobbyists, with the fuzzy_score set as an attribute
    #
    # Usage:
    #
    # lobbyists = Lobbyist.search("Nisha Thompsen")
    # lobbyists = Lobbyist.search("Michael Klein", year=2007, threshold=0.9)
    def self.search_by_name(name, params={})
      threshold = params[:threshold] || '0.8'
      year = params[:year]
      
      if year.nil?
        url = construct_url("lobbyists.search", :name => name,
                            :threshold => threshold)
      else
        url = construct_url("lobbyists.search", :name => name,
                            :year => year, :threshold => threshold)
      end

      if (results = get_json_data(url))
        lobbyists = []
        results["response"]["results"].each do |result|
          if result
            lobbyist = Lobbyist.new(result["result"]["lobbyist"])
            fuzzy_score = result["result"]["score"]

            if threshold.to_f < fuzzy_score.to_f
              lobbyist.fuzzy_score = fuzzy_score.to_f
              lobbyists << lobbyist
            end
          end
        end

        if lobbyists.empty?
          nil
        else
          lobbyists
        end
        
      else
        nil
      end
    end # def self.search
  end # class Lobbyist
end # module Sunlight
