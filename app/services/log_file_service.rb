require 'open-uri'
class LogFileService

  def process_log_file(file_url)
    response = {}
    open(file_url, 'r').each do |line|
      _, timestamp, exception = line.split(' ')

      time_value = Time.zone.strptime(timestamp.to_s, '%Q')
      time_range = create_range(time_value.hour, time_value.min)

      response[time_range] = {} if response[time_range].blank?
      response[time_range][exception] = 0 if response[time_range][exception].blank?
      response[time_range][exception] = response[time_range][exception] + 1
    end

    response
  end

  def create_range(hour, minutes)
    case minutes
      when 0..15
        return format_range(hour, 0, 15)
      when 15..30
        return format_range(hour, 15, 30)
      when 30..45
        return format_range(hour, 30, 45)
      when 45..59
        return format_range(hour, 45, 0, true)
      end
  end

  def format_range(hour, start_min, end_min, cycle=false)
    next_hour = hour
    next_hour += 1 if cycle == true
    [Time.parse("#{hour}:#{start_min}").strftime("%H:%M"), Time.parse("#{next_hour}:#{end_min}").strftime("%H:%M")].join('-')
  end

  def format_log_response(response)
    res = {}
    response.each do |file_res|
      file_res.each do |time_range, data|
        res[time_range] = {} if res[time_range].blank?
        data.each do |exception, count|
          res[time_range][exception] = 0 if res[time_range][exception].blank?
          res[time_range][exception] = res[time_range][exception] + count
        end
      end
    end

    final_response = []

    res.each do |range, data|
      logs = []
      data.each do |key, value|
        logs << {exception: key, count: value}
      end
      final_response << {
        timestamp: range,
        logs: logs
      }
    end

    final_response
  end
end
