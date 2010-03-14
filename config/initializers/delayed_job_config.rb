silence_warnings do
  Delayed::Worker::sleep_delay = 5
  Delayed::Job::max_attempts = 2
  Delayed::Job::max_run_time = 5.minutes
end