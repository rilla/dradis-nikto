require 'spec_helper'

describe 'Nikto upload plugin' do
  describe "Importer" do

    before(:each) do
      # Stub template service
      templates_dir = File.expand_path('../../templates', __FILE__)
      expect_any_instance_of(Dradis::Plugins::TemplateService)
      .to receive(:default_templates_dir).and_return(templates_dir)

      # Init services
      plugin = Dradis::Plugins::Nikto

      @content_service = Dradis::Plugins::ContentService.new(plugin: plugin)
      template_service = Dradis::Plugins::TemplateService.new(plugin: plugin)

      @importer = plugin::Importer.new(
        content_service: @content_service,
        template_service: template_service
      )

      # Stub dradis-plugins methods
      #
      # They return their argument hashes as objects mimicking
      # Nodes, Issues, etc
      allow(@content_service).to receive(:create_node) do |args|
        puts "create_node: #{ args.inspect }"
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_note) do |args|
        puts "create_note: #{ args.inspect }"
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_issue) do |args|
        puts "create_issue: #{ args.inspect }"
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_evidence) do |args|
        puts "create_evidence: #{ args.inspect }"
        OpenStruct.new(args)
      end
    end

    it "creates nodes, issues, notes and an evidences as needed" do
      # Host node and basic host info note
      expect(@content_service).to receive(:create_node) do |args|
        expect(args[:label]).to eq('http://localhost:80/')
        expect(args[:type]).to eq(:host)
        OpenStruct.new(args)
      end.once
      expect(@content_service).to receive(:create_note) do |args|
        expect(args[:text]).to include("#[Title]#\nNikto upload: localhost.xml")
        expect(args[:node].label).to eq("http://localhost:80/")
        OpenStruct.new(args)
      end.once

      expect(@content_service).to receive(:create_node) do |args|
        expect(args[:label]).to eq('750000')
        expect(args[:parent].label).to eq("http://localhost:80/")
        OpenStruct.new(args)
      end.once
      expect(@content_service).to receive(:create_note) do |args|
        expect(args[:node].label).to eq("750000")
        expect(args[:text]).to include("/: Directory indexing found.")
        OpenStruct.new(args)
      end.once

      expect(@content_service).to receive(:create_node) do |args|
        expect(args[:label]).to eq('600050')
        expect(args[:parent].label).to eq("http://localhost:80/")
        OpenStruct.new(args)
      end.once
      expect(@content_service).to receive(:create_note) do |args|
        expect(args[:node].label).to eq("600050")
        expect(args[:text]).to include("Apache/2.2.16 appears to be outdated")
        OpenStruct.new(args)
      end.once

      expect(@content_service).to receive(:create_node) do |args|
        expect(args[:label]).to eq('999990')
        expect(args[:parent].label).to eq("http://localhost:80/")
        OpenStruct.new(args)
      end.once
      expect(@content_service).to receive(:create_note) do |args|
        expect(args[:node].label).to eq("999990")
        expect(args[:text]).to include("Allowed HTTP Methods: GET, HEAD, POST, OPTIONS")
        OpenStruct.new(args)
      end.once

      expect(@content_service).to receive(:create_node) do |args|
        expect(args[:label]).to eq('750000')
        expect(args[:parent].label).to eq("http://localhost:80/")
        OpenStruct.new(args)
      end.once
      expect(@content_service).to receive(:create_note) do |args|
        expect(args[:node].label).to eq("750000")
        expect(args[:text]).to include("/?show=http://cirt.net/rfiinc.txt??: Directory indexing found.")
        OpenStruct.new(args)
      end.once

      # Run the import
      @importer.import(file: 'spec/fixtures/files/localhost.xml')
    end

  end
end
