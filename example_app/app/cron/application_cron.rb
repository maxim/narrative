class ApplicationCron
  # Wrap code into `isolate` blocks so that each block can error out without
  # stopping other blocks.
  def isolate
    yield
  rescue => e
    Rails.logger.error(e.message)
  end
end
