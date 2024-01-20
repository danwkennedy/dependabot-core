# typed: true
# frozen_string_literal: true

require "dependabot/update_checkers"
require "dependabot/update_checkers/base"
require "dependabot/errors"

module SilentPackageManager
  class UpdateChecker < Dependabot::UpdateCheckers::Base
    def latest_version
      available_versions.max.to_s
    end

    def up_to_date?
      dependency.version == latest_version
    end

    def can_update?(*)
      true
    end

    def latest_resolvable_version
      latest_version
    end

    def updated_requirements
      dependency.requirements.map do |req|
        req.merge(requirement: "9.9.9")
      end
    end

    private

    def available_versions
      return @available_versions if defined? @available_versions

      # the available versions are stored in a file in the repo
      # that's why this package manager is silent, makes no requests
      contents = File.read(File.join(repo_contents_path, dependency.name))
      available_versions = JSON.parse(contents)["versions"]
      @available_versions = available_versions.map { |v| SilentPackageManager::Version.new(v) }
    end
  end
end

Dependabot::UpdateCheckers.register("silent", SilentPackageManager::UpdateChecker)
