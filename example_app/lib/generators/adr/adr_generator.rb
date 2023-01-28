class AdrGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  desc "Create a new architectural decision record file in doc/adr"
  def create_adr_file
    @today = Date.current
    prefix = @today.strftime("%Y-%m")
    template "adr.md", "doc/adr/#{prefix}-#{name.dasherize}.md"
  end
end
