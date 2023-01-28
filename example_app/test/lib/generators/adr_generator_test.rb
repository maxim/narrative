require "test_helper"
require "generators/adr/adr_generator"

class AdrGeneratorTest < Rails::Generators::TestCase
  tests AdrGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "inserts correct name and date" do
    today = Date.current

    assert_nothing_raised do
      run_generator ["sample_adr"]
    end

    assert_file "doc/adr/#{today.strftime("%Y-%m")}-sample-adr.md" do |file|
      assert_match(/# Sample Adr/, file.lines[0])
      assert_match("* **Last Updated:** #{today}", file)
    end
  end
end
