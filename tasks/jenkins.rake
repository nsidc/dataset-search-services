# frozen_string_literal: true

def version_rb
  File.expand_path('../lib/version.rb', __dir__)
end

# Load will reload the version file so we can get the updated value
# after bumping it.
def current_version
  load version_rb
  Version::VERSION
end

namespace :jenkins do
  namespace :release do
    date = Time.now.strftime('%Y-%m-%d')

    desc 'Bump version part (patch/minor/major), set release date in CHANGELOG, make tag'
    task :bump, [:part] do |_t, args|
      args.with_defaults(part: 'patch')

      # bump VERSION in version.rb, stage version.rb
      sh "bundle exec bump #{args[:part]} --no-commit"
      sh "git add #{version_rb}"
      version = current_version

      # change "Unreleased" version to current version, with a release date of
      # today, stage CHANGELOG.md
      changelog_md = File.expand_path('../CHANGELOG.md', __dir__)
      sh %(sed -i "s/^## Unreleased$/## v#{version} (#{date})/" #{changelog_md})
      sh %(git add #{changelog_md})

      # commit changes and tag
      sh %(git commit -m "v#{version}")
      sh %(git tag v#{version})
    end

    desc 'git-push the release changes (the version bump commit and the version tag)'
    task :push do
      current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
      sh "git push origin #{current_branch} --tags"
    end

    desc 'Update git with a tag to show which ref is deployed to which environment'
    task :tag_deployment, [:env] do |_t, args|
      sh "git tag --force #{args[:env]}"
      sh "git push --force origin refs/tags/#{args[:env]}"
    end
  end
end
