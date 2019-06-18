RSpec.describe CfnCamelizer do
  let(:camelizer) { CfnCamelizer }
  context "not camelize the special cases" do
    it "transform should not transform keys under Fn::Sub" do
      data = {"UserData"=>{"Fn::Sub"=>["hello", {"k1"=>"v1", "k2"=>"v2"}]}}
      result = camelizer.transform(data)
      expect(result).to eq(data)
    end
  end

  it "simple string" do
    s = "foo_bar"
    s = camelizer.camelize(s)
    expect(s).to eq "FooBar"
  end

  it "transform keys" do
    h = {foo_bar: 1}
    result = camelizer.transform(h)
    result.keys == ["FooBar"]
  end

  it "do not pasalize anything under Variables" do
    h = {foo_bar: 1, variables: {dont_touch: 2}}
    result = camelizer.transform(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "Variables"=>{"dont_touch"=>2})
  end

  # CloudWatch Event patterns have slightly different casing
  it "dasherize anything under EventPattern at the top level" do
    h = {foo_bar: 1, event_pattern: {dash_me: 2}}
    result = camelizer.transform(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "EventPattern"=>{"dash-me"=>2})
  end

  it "camelize anything under EventPattern at any level beyond the top level" do
    h = {foo_bar: 1, event_pattern: {dash_me: {camelize_me: 3}}}
    result = camelizer.transform(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "EventPattern"=>{"dash-me"=>{"camelizeMe"=>3}})
  end

  it "dont touch anything under ResponseParameters" do
    h = {foo_bar: 1, response_parameters: {dont_touch: 3}}
    result = camelizer.transform(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "ResponseParameters"=>{"dont_touch"=>3})
  end

  it "dont touch anything with - or /" do
    h = {foo_bar: 1, "has-dash": 2, "has/slash": 3,"application/json":4}
    result = camelizer.transform(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "has-dash"=>2,"has/slash"=>3,"application/json"=>4)
  end

  it "special map keys" do
    h = {template_url: 1, ttl: 60}
    result = camelizer.transform(h)
    # pp result
    expect(result).to eq("TemplateURL"=>1, "TTL"=> 60)
  end

  it "role_arn property under AWS::Events::Rule type maintains normal RoleArn camelization" do
    h = {
      events_rule: {
        type: "AWS::Events::Rule",
        properties: {
          role_arn: "some.arn"
        }
      }
    }
    result = camelizer.transform(h)
    # pp result
    expect(result).to eq({"EventsRule"=>{"Type"=>"AWS::Events::Rule", "Properties"=>{"RoleArn"=>"some.arn"}}})
  end
end
