class JobsController < ActionController::Base
  autocomplete :job, :title, :full => true, :extra_data => [:code]
end
