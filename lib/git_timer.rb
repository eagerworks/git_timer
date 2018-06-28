require 'git_timer/version'
require 'git_timer/cli'

module GitTimer extend self
  require 'fileutils'
  require 'time'

  MAIN_PATH = './user-log'
  PRE_PUSH_PATH = '.git/hooks/pre-push'
  POST_CHECKOUT_PATH = '.git/hooks/post-checkout'
  LOG_TITLE = "# Git log \n"

  def main
    unless File.exist?(MAIN_PATH)
      File.open(MAIN_PATH, 'w+') do |f|
        f.write LOG_TITLE
      end
      File.chmod(0777, MAIN_PATH)
    end
    initialize_git_hook(POST_CHECKOUT_PATH, 'post_checkout') unless File.exist?(POST_CHECKOUT_PATH)
    initialize_git_hook(PRE_PUSH_PATH, 'pre_push') unless File.exist?(PRE_PUSH_PATH)
  end

  def initialize_git_hook(hook_path, hook_method)
    content =
    "#!/usr/bin/env ruby

    require 'git_timer'

    GitTimer.#{hook_method}
    "
    File.open(hook_path, 'w+') do |f|
      f.write content
    end
    FileUtils.chmod('+x', hook_path)
  end

  def post_checkout
    current_branch, ticket_id = current_branch_and_ticket_id
    previous_head = ARGV[0]
    new_head = ARGV[1]
    is_file_checkout = ARGV[2] == '0'
    if is_file_checkout
      puts 'This is a file checkout. Nothing to do.'
      exit 0
    end
    if is_new_branch?(current_branch, previous_head, new_head)
      register_activity({ ticket_id: ticket_id, ticket_state: 'In progress' })
    end
  end

  def pre_push
    _, ticket_id = current_branch_and_ticket_id
    if failed_push?(ticket_id)
      new_lines = File.readlines(MAIN_PATH)
      new_lines.pop
      File.open(MAIN_PATH, 'w') do |f|
        new_lines.each do |line|
          f.write line
        end
      end
    end
    register_activity({ ticket_id: ticket_id, ticket_state: 'Code review' })
  end

  def is_new_branch?(current_branch, previous_head, new_head)
    # if the refs of the previous and new heads are the same
    # and the number of checkouts equals one, a new branch has been created
    num_checkouts = `git reflog --date=local | grep -o #{current_branch} | wc -l`.strip.to_i
    previous_head == new_head && num_checkouts == 1
  end

  def current_branch_and_ticket_id
    list_of_branches = `git branch`.split("\n")
    current_branch = list_of_branches.find { |string| string.match(/^\* /) }.sub('* ', '')
    ticket_id = current_branch.match(/^([^_]*)_?/)
    ticket_id = ticket_id.captures.first if ticket_id != nil
    [current_branch, ticket_id]
  end

  def failed_push?(ticket_id)
    last_entry = `tail -n 1 #{MAIN_PATH}`
    return false if last_entry == LOG_TITLE
    last_entry = last_entry.match(/^(\w*) \| (\w* \w*) \| (.*)/).captures
    time_diff = (Time.now - Time.parse(last_entry[2])) / 60
    last_entry[0] == ticket_id && last_entry[1] == 'Code review' && time_diff < 11
  end

  def register_activity(ticket_info)
    ticket_id = ticket_info[:ticket_id]
    ticket_state = ticket_info[:ticket_state]
    File.open(MAIN_PATH, 'a') do |f|
      f.puts "#{ticket_id} | #{ticket_state} | #{Time.now}"
    end
  end
end

