module RSpecSystemHelper
  def configure_rspec_adapter
    driven_by(:rack_test)
  end
end