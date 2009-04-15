require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "have_xpath" do
  include Webrat::Matchers

  before(:each) do
    @body = <<-HTML
      <div id='main'>
        <div class='inner'>hello, world!</div>
        <h2>Welcome "Bryan"</h2>
        <h3>Welcome 'Bryan'</h3>
        <h4>Welcome 'Bryan"</h4>
        <ul>
          <li>First</li>
          <li>Second</li>
        </ul>
      </div>
    HTML
  end

  it "should be able to match an XPATH" do
    @body.should have_xpath("//div")
  end

  it "should be able to match an XPATH with attributes" do
    @body.should have_xpath("//div", :class => "inner")
  end

  it "should be able to match an XPATH with content" do
    @body.should have_xpath("//div", :content => "hello, world!")
  end

  it "should not match an XPATH without content" do
    @body.should_not have_xpath("//div", :content => "not present")
  end

  it "should be able to match an XPATH with content and class" do
    @body.should have_xpath("//div", :class => "inner", :content => "hello, world!")
  end

  it "should not match an XPATH with content and wrong class" do
    @body.should_not have_xpath("//div", :class => "outer", :content => "hello, world!")
  end

  it "should not match an XPATH with wrong content and class" do
    @body.should_not have_xpath("//div", :class => "inner", :content => "wrong")
  end

  it "should not match an XPATH with wrong content and wrong class" do
    @body.should_not have_xpath("//div", :class => "outer", :content => "wrong")
  end

  it "should not match a XPATH that does not exist" do
    @body.should_not have_xpath("//p")
  end

  it "should be able to loop over all the matched elements" do
    @body.should have_xpath("//div") do |node|
      node.first.name.should == "div"
    end
  end

  it "should not match if any of the matchers in the block fail" do
    lambda {
      @body.should have_xpath("//div") do |node|
        node.first.name.should == "p"
      end
    }.should raise_error(Spec::Expectations::ExpectationNotMetError)
  end

  it "should be able to use #have_xpath in the block" do
    @body.should have_xpath("//div[@id='main']") do |node|
      node.should have_xpath("./div[@class='inner']")
    end
  end

  it "should convert absolute paths to relative in the block" do
    @body.should have_xpath("//div[@id='main']") do |node|
      node.should have_xpath("//div[@class='inner']")
    end
  end

  it "should not match any parent tags in the block" do
    lambda {
      @body.should have_xpath("//div[@class='inner']") do |node|
        node.should have_xpath("//div[@id='main']")
      end
    }.should raise_error(Spec::Expectations::ExpectationNotMetError)
  end

  describe 'asserts for xpath on default response_body' do
    include Test::Unit::Assertions

    before(:each) do
      should_receive(:response_body).and_return @body
      require 'test/unit'
    end

    describe "assert_have_xpath" do
      it "should pass when body contains the selection" do
        assert_have_xpath("//div")
      end

      it "should pass when body contains selection with attributes" do
        assert_have_selector("li", :content => "First")
      end

      it "should throw an exception when the body doesnt have matching xpath" do
        lambda {
          assert_have_xpath("//p")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end

      it "should construct and call matcher correctly without attributes" do
        matcher = mock('have_xpath', :null_object => true)
        Webrat::Matchers::HaveXpath.should_receive(:new).with("//div", {}).and_return(matcher)

        matcher.should_receive(:matches?).with(@body)

        stub!(:assert)

        assert_have_xpath("//div")
      end

      it "should construct and call matcher correctly with attributes" do
        matcher = mock('have_xpath', :null_object => true)
        Webrat::Matchers::HaveXpath.should_receive(:new).with("//li", {:content => "First"}).and_return(matcher)

        matcher.should_receive(:matches?).with(@body)

        stub!(:assert)

        assert_have_xpath("//li", :content => "First")
      end
    end

    describe "assert_have_no_xpath" do
      it "should pass when the body doesn't contan the xpath" do
        assert_have_no_xpath("//p")
      end

      it "should throw an exception when the body does contain the xpath" do
        lambda {
          assert_have_no_xpath("//div")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end

      it "should construct and call matcher correctly without attributes" do
        matcher = mock('have_xpath', :null_object => true)
        Webrat::Matchers::HaveXpath.should_receive(:new).with("//li", {}).and_return(matcher)

        matcher.should_receive(:matches?).with(@body)

        stub!(:assert)

        assert_have_no_xpath("//li")
      end

      it "should construct and call matcher correctly with attributes" do
        matcher = mock('have_xpath', :null_object => true)
        Webrat::Matchers::HaveXpath.should_receive(:new).with("//li", {:content => "First"}).and_return(matcher)

        matcher.should_receive(:matches?).with(@body)

        stub!(:assert)

        assert_have_no_xpath("//li", :content => "First")
      end
    end
  end

  describe "Test::Unit assertions on stringlike object" do
    include Test::Unit::Assertions

    before(:each) do
      should_not_receive(:response_body).and_return @body
      require 'test/unit'
    end

    describe "assert_have_xpath" do
      it "should pass when body contains the selection" do
        assert_have_xpath("//div", @body)
      end

      it "should construct and call matcher correctly without attributes" do
        matcher = mock('have_xpath', :null_object => true)
        Webrat::Matchers::HaveXpath.should_receive(:new).with("//div", {}).and_return(matcher)

        matcher.should_receive(:matches?).with(@body)

        stub!(:assert)

        assert_have_xpath("//div", @body)
      end

      it "should construct and call matcher correctly with attributes" do
        matcher = mock('have_xpath', :null_object => true)
        Webrat::Matchers::HaveXpath.should_receive(:new).with("//li", {:content => "First"}).and_return(matcher)

        matcher.should_receive(:matches?).with(@body)

        stub!(:assert)

        assert_have_xpath("//li", {:content => "First"}, @body)
      end
    end

    describe "assert_have_no_xpath" do
      it "should pass when the body doesn't contan the xpath" do
        assert_have_no_xpath("//p", @body)
      end

      it "should construct and call matcher correctly without attributes" do
        matcher = mock('have_xpath', :null_object => true)
        Webrat::Matchers::HaveXpath.should_receive(:new).with("//li", {}).and_return(matcher)

        matcher.should_receive(:matches?).with(@body)

        stub!(:assert)

        assert_have_no_xpath("//li", @body)
      end

      it "should construct and call matcher correctly with attributes" do
        matcher = mock('have_xpath', :null_object => true)
        Webrat::Matchers::HaveXpath.should_receive(:new).with("//li", {:content => "First"}).and_return(matcher)

        matcher.should_receive(:matches?).with(@body)

        stub!(:assert)

        assert_have_no_xpath("//li", { :content => "First" }, @body)
      end
    end

  end
end
