require 'spec_helper'
require 'axe/api/a11y_check'

module Axe::API
  describe A11yCheck do

    describe "@context" do
      let(:context) { spy('context') }
      before :each do
        subject.instance_variable_set :@context, context
      end

      it "should be delegated #include as #within" do
        subject.within :foo
        expect(context).to have_received(:include).with(:foo)
      end

      it "should be delegated #exclude as #excluding" do
        subject.excluding :foo
        expect(context).to have_received(:exclude).with(:foo)
      end
    end

    describe "@options" do
      let(:options) { spy('options') }
      before :each do
        subject.instance_variable_set :@options, options
      end

      it "should be delegated #rules_by_tags as #according_to" do
        subject.according_to :foo
        expect(options).to have_received(:rules_by_tags).with(:foo)
      end

      it "should be delegated #run_rules as #checking" do
        subject.checking :foo
        expect(options).to have_received(:run_rules).with( :foo)
      end

      it "should be delegated #run_only_rules as #checking_only" do
        subject.checking_only :foo
        expect(options).to have_received(:run_only_rules).with( :foo)
      end

      it "should be delegated #skip_rules as #skipping" do
        subject.skipping :foo
        expect(options).to have_received(:skip_rules).with( :foo)
      end

      it "should be delegated #custom_options as #with_options" do
        subject.with_options :foo
        expect(options).to have_received(:custom_options).with(:foo)
      end
    end

    describe "chainable api" do
      its(:within) { is_expected.to be subject }
      its(:excluding) { is_expected.to be subject }
      its(:according_to) { is_expected.to be subject }
      its(:checking) { is_expected.to be subject }
      its(:checking_only) { is_expected.to be subject }
      its(:skipping) { is_expected.to be subject }
      its(:with_options) { is_expected.to be subject }
    end

    describe "#call" do
      let(:page) { spy('page', execute_async_script: {'violations' => []}) }
      let(:results) { spy('results') }
      let(:audit) { spy('audit') }

      it "should inject the axe-core lib" do
        subject.call(page)
        expect(page).to have_received(:execute_script).with(a_string_starting_with ("/*! aXe"))
      end

      it "should execute the the A11yCheck script" do
        pending "validate args correctly"
        subject.call(page)
        expect(page).to have_received(:execute_async_script).with("axe.a11yCheck.apply(axe, arguments)", "document", "{}")
      end

      it "should return an audit" do
        expect(subject.call(page)).to be_kind_of Audit
      end

      it "should parse the results" do
        expect(Results).to receive(:new).with('violations' => []).and_return results
        expect(Audit).to receive(:new).with(instance_of(String), results)
        subject.call(page)
      end

      it "should include the original invocation string" do
        expect(Audit).to receive(:new).with("axe.a11yCheck(document, {}, callback);", instance_of(Results))
        subject.call(page)
      end
    end
  end
end
