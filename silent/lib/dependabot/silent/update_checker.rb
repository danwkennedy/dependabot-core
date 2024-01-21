# typed: true
# frozen_string_literal: true

require "dependabot/update_checkers"
require "dependabot/update_checkers/base"
require "dependabot/errors"
require "dependabot/update_checkers/version_filters"

module SilentPackageManager
  class UpdateChecker < Dependabot::UpdateCheckers::Base
    def latest_version
      available_versions.max.to_s
    end

    def lowest_security_fix_version
      Dependabot::UpdateCheckers::VersionFilters.filter_vulnerable_versions(
        available_versions,
        security_advisories
      ).min.to_s
    end

    def lowest_resolvable_security_fix_version
      raise "Dependency not vulnerable!" unless vulnerable?

      lowest_security_fix_version
    end

    def up_to_date?
      dependency.version == latest_version
    end

    def latest_resolvable_version
      latest_version
    end

    def updated_requirements
      dependency.requirements.map do |req|
        req.merge(requirement: preferred_resolvable_version)
      end
    end

    private

    def available_versions
      return @available_versions if defined? @available_versions

      version_file = File.join(repo_contents_path, dependency.name)
      return [] unless File.exist?(version_file)

      # the available versions are stored in a file in the repo
      # that's why this package manager is silent, makes no requests
      contents = File.read(version_file)
      available_versions = JSON.parse(contents)["versions"]
      @available_versions = available_versions.map { |v| SilentPackageManager::Version.new(v) }
    rescue JSON::ParserError
      raise Dependabot::DependencyFileNotParseable, dependency_files.first.path
    end
  end
end

Dependabot::UpdateCheckers.register("silent", SilentPackageManager::UpdateChecker)
