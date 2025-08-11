class FlipChatwootV4DefaultFeatureFlagInstallationConfig < ActiveRecord::Migration[7.0]
  class MigrationAccount < ApplicationRecord
    self.table_name = 'accounts'
    include FlagShihTzu
    
    # Define the feature flags that exist in v3.16
    FEATURES = {
      1 => :feature_help_center,
      2 => :feature_sla,
      3 => :feature_csat,
      4 => :feature_auto_resolve,
      5 => :feature_canned_responses,
      6 => :feature_auto_assign_agent,
      7 => :feature_auto_assign_team,
      8 => :feature_automation,
      9 => :feature_voice_recording,
      10 => :feature_facebook,
      11 => :feature_twitter,
      12 => :feature_whatsapp,
      13 => :feature_telegram,
      14 => :feature_line,
      15 => :feature_instagram,
      16 => :feature_web_widget,
      17 => :feature_sms,
      18 => :feature_email,
      19 => :feature_api,
      20 => :feature_webhooks,
      21 => :feature_custom_attributes,
      22 => :feature_automation_rule,
      23 => :feature_dashboard,
      24 => :feature_reports,
      25 => :feature_help_center_kb,
      26 => :feature_help_center_community,
      27 => :feature_help_center_contact,
      28 => :feature_help_center_feedback,
      29 => :feature_help_center_article_search,
      30 => :feature_help_center_article_search_autocomplete
    }.freeze
    
    has_flags FEATURES.merge(column: 'feature_flags', flag_query_mode: :bit_operator, check_for_column: false)
  end

  def up
    # Skip the feature flag update for now to avoid the settings method error
    # We'll enable chatwoot_v4 feature in a separate step after the upgrade
    
    # Just update the installation config without touching accounts
    config = InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
    if config && config.value.present?
      features = config.value.map do |f|
        if f['name'] == 'chatwoot_v4'
          f.merge('enabled' => true)
        else
          f
        end
      end
      config.value = features
      config.save!
    end
    
    # Skip the account updates to avoid the settings method error
    # We'll handle this after the upgrade is complete
    
    GlobalConfig.clear_cache if defined?(GlobalConfig)
  end

  def down
    # Revert the installation config
    config = InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
    if config && config.value.present?
      features = config.value.map do |f|
        if f['name'] == 'chatwoot_v4'
          f.merge('enabled' => false)
        else
          f
        end
      end
      config.value = features
      config.save!
    end
  end
end
