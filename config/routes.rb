Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'api/process-logs' => 'api/process_logs#process_log_files'
end
