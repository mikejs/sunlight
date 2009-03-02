require File.dirname(__FILE__) + '/spec_helper'

describe Sunlight::Filing do

  before(:each) do

    Sunlight.api_key = 'the_api_key'
    @example_hash = {"client_name" => "SUNLIGHT FOUNDATION", "filing_year" => "2007"}

  end

  describe "#initialize" do

    it "should create an object from a JSON parser-generated hash" do
      sf = Filing.new(@example_hash)
      sf.should be_an_instance_of(Filing)
      sf.client_name.should eql("SUNLIGHT FOUNDATION")
    end

  end

  describe "#all_where" do
    
    it "should return array when valid parameters are passed in" do
      Sunlight::Filing.should_receive(:get_json_data).and_return({"response"=>{"filings"=>[{"filing"=>{"client_name"=>"ABC", "lobbyists" => [{"lobbyist" => {"firstname" => "Bob"}}], "issues" => [{"issue" => {"specific_issue" => "Issue"}}]}}]}})
      
      filings = Sunlight::Filing.all_where(:client_name => "ABC", :year => '2007')
      filings.first.client_name.should eql('ABC')
    
      filings.first.lobbyists.first.should be_an_instance_of(Lobbyist)
      filings.first.lobbyists.first.firstname.should eql("Bob")
      
      filings.first.issues.first.should be_an_instance_of(Issue)
      filings.first.issues.first.specific_issue.should eql("Issue")
    end
        
    it "should return nil on bad data" do
      filings = Sunlight::Filing.all_where(:foo => "bar")
      filings.should be(nil)      
    end    
    
    it "should return nil on failed search" do
      Sunlight::Filing.should_receive(:get_json_data).and_return(nil)
      
      filings = Sunlight::Filing.all_where(:client_name => "bar")
      filings.should be(nil)
    end
    
    it "should return nil on empty search" do
      Sunlight::Filing.should_receive(:get_json_data).and_return({"response" => {"filings" => []}})
      
      filings = Sunlight::Filing.all_where(:client_name => "abc")
      filings.should be(nil)
    end
    
  end
  
  describe "#get" do

    it "should return nil if no match is found" do
      Sunlight::Filing.should_receive(:get_json_data).and_return(nil)
      
      filing = Sunlight::Filing.get("bad ID")
      filing.should be(nil)
    end
    
    it "should return nil on empty reply" do
      Sunlight::Filing.should_receive(:get_json_data).and_return({"response" => {}})
      
      filing = Sunlight::Filing.get("bad ID")
      filing.should be(nil)
    end

    it "should return one record when id is passed in" do
      Sunlight::Filing.should_receive(:get_json_data).and_return({"response" => {"filing"=> {"client_name" => "ABC", "lobbyists" => [{"lobbyist" => {"firstname" => "Bob"}}], "issues" => [{"issue" => {"specific_issue" => "Issue"}}]}}})

      filing = Filing.get("real ID")
      filing.should be_an_instance_of(Filing)
      filing.client_name.should eql('ABC')
      
      filing.lobbyists.first.should be_an_instance_of(Lobbyist)
      filing.lobbyists.first.firstname.should eql("Bob")
      
      filing.issues.first.should be_an_instance_of(Issue)
      filing.issues.first.specific_issue.should eql("Issue")
    end

  end

end


describe Sunlight::Issue do

  before(:each) do
    @example_hash = {"code" => "123", "specific_issue" => "Important Stuff"}
  end

  describe "#initialize" do

    it "should create an object from a JSON parser-generated hash" do
      issue = Issue.new(@example_hash)
      issue.should be_an_instance_of(Issue)
      issue.specific_issue.should eql("Important Stuff")
    end

  end
  
end

describe Sunlight::Lobbyist do

  before(:each) do

    Sunlight.api_key = 'the_api_key'
    @example_hash = {"firstname" => "Bob", "middlename" => "J.", "lastname" => "Smith", "suffix" => "Jr."} 

  end

  describe "#initialize" do

    it "should create an object from a JSON parser-generated hash" do
      bob = Lobbyist.new(@example_hash)
      bob.should be_an_instance_of(Lobbyist)
      bob.firstname.should eql("Bob")
    end

  end

  describe "#search_by_name" do
    
    it "should return array when probable match passed in with no threshold" do
      Sunlight::Lobbyist.should_receive(:get_json_data).and_return({"response"=>{"results"=>[{"result"=>{"score"=>"0.91", "lobbyist"=>{"firstname"=>"Edward"}}}]}})
      
      lobbyists = Sunlight::Lobbyist.search_by_name("Teddy Kennedey")
      lobbyists.first.fuzzy_score.should eql(0.91)
      lobbyists.first.firstname.should eql('Edward')
    end
    
    it "should return an array when probable match passed in is over supplied threshold" do
      Sunlight::Lobbyist.should_receive(:get_json_data).and_return({"response"=>{"results"=>[{"result"=>{"score"=>"0.91", "lobbyist"=>{"firstname"=>"Edward"}}}]}})

      lobbyists = Sunlight::Lobbyist.search_by_name("Teddy Kennedey", :threshold => 0.9)
      lobbyists.first.fuzzy_score.should eql(0.91)
      lobbyists.first.firstname.should eql('Edward')
    end
    
    it "should return nil when probable match passed in but underneath supplied threshold" do
      Sunlight::Lobbyist.should_receive(:get_json_data).and_return({"response"=>{"results"=>[{"result"=>{"score"=>"0.91", "lobbyist"=>{"firstname"=>"Edward"}}}]}})
    
      lobbyists = Sunlight::Lobbyist.search_by_name("Teddy Kennedey", :threshold => 0.92, :year => "2005")
      lobbyists.should be(nil)
    end
    
    it "should return nil when no probable match at all" do
      Sunlight::Lobbyist.should_receive(:get_json_data).and_return({"response"=>{"results"=>[]}})
    
      lobbyists = Sunlight::Lobbyist.search_by_name("923jkfkj elkji")
      lobbyists.should be(nil)      
    end
    
    it "should return nil on bad data" do
      Sunlight::Lobbyist.should_receive(:get_json_data).and_return(nil)
    
      lobbyists = Sunlight::Lobbyist.search_by_name("923jkfkj elkji","lkjd")
      lobbyists.should be(nil)      
    end    
    
  end

end
