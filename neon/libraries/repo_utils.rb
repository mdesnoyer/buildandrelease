class Chef
  class Recipe

    # Returns the directory where the repo will be for a given app name
    def get_repo_path(app_name)
      if app_name.nil? or node[:deploy].nil? or node[:deploy][app_name].nil? then
        relpath = "core"
      elsif node[:deploy][app_name][:document_root].nil? then
        relpath = app_name.downcase.tr(' ', '')
      else
        relpath = node[:deploy][app_name][:document_root]
      end

      return "#{node[:neon][:code_root]}/#{relpath}"
    end
  end
end
