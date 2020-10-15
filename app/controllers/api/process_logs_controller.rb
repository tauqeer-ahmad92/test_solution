require 'open-uri'
class Api::ProcessLogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def process_log_files
    set_log_file_params
    reason = validate_params
    return invalid_response(reason) if reason.present?

    file_url = @log_files.first

    log_file_service = LogFileService.new
    @combined_response = []

    Parallel.each_with_index(@log_files, in_threads: @processing_counter.to_i) do |file, index|
      @combined_response << log_file_service.process_log_file(file)
    end

    return render json: log_file_service.format_log_response(@combined_response), status: :ok
  end

  private

  def validate_params
    return 'Please provide valid params.' if @processing_counter.blank? || @log_files.blank?
    return 'Parallel File Processing count must be greater than zero!' if @processing_counter.to_i <= 0
  end

  def set_log_file_params
    @log_files = params['logFiles']
    @processing_counter = params['parallelFileProcessingCount']
  end

  def invalid_response(reason)
    return render json: {status: 'failure', reason: reason}, status: :bad_request
  end
end
