def expect_running(running)
  expect_any_instance_of(cib_object_class) \
    .to receive(:running?) \
    .and_return(running)
end

shared_examples "a runnable resource" do

  describe ":start action" do
    it_should_behave_like "action on non-existent resource", \
      :start,
      "crm resource start #{fixture.name}", \
      "Cannot start non-existent resource primitive '#{fixture.name}'"

    it "should do nothing to a started resource" do
      expect_definition(fixture.definition_string)
      expect_running(true)

      provider.run_action :start

      cmd = "crm resource start #{fixture.name}"
      expect(@chef_run).not_to run_execute(cmd)
      expect(@resource).not_to be_updated
    end

    it "should start a stopped resource" do
      config = fixture.definition_string.sub("Started", "Stopped")
      expect_definition(config)
      expect_running(false)

      provider.run_action :start

      cmd = "crm resource start '#{fixture.name}'"
      expect(@chef_run).to run_execute(cmd)
      expect(@resource).to be_updated
    end
  end

  describe ":stop action" do
    it_should_behave_like "action on non-existent resource", \
      :stop,
      "crm resource stop #{fixture.name}", \
      "Cannot stop non-existent resource primitive '#{fixture.name}'"

    it "should do nothing to a stopped resource" do
      expect_definition(fixture.definition_string)
      expect_running(false)

      provider.run_action :stop

      cmd = "crm resource start #{fixture.name}"
      expect(@chef_run).not_to run_execute(cmd)
      expect(@resource).not_to be_updated
    end

    it "should stop a started resource" do
      expect_definition(fixture.definition_string)
      expect_running(true)

      provider.run_action :stop

      cmd = "crm resource stop '#{fixture.name}'"
      expect(@chef_run).to run_execute(cmd)
      expect(@resource).to be_updated
    end
  end
end
