require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'pry' if Rails.env == "development"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Diy
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)

    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      html = %(#{html_tag}).html_safe

      elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, input"
      elements.each do |e|
        if e.node_name.eql? 'label'
          if instance.error_message.kind_of?(Array)
            html = %(#{html_tag}<span class="invalid">&nbsp;#{instance.error_message.join(', ')}</span>).html_safe
          else
            html = %(#{html_tag}<span class="help-inline">&nbsp;#{instance.error_message}</span>).html_safe
          end
        end
      end
      html
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
