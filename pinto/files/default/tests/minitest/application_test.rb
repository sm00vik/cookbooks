class PintoSpec < MiniTest::Chef::Spec

    include PintoLibrary

    describe 'installs pinto' do

        it 'creates pinto user/group' do
            group("#{node[:pinto][:group]}").must_exist
            user("#{node[:pinto][:user]}").must_exist.with(:group, "#{node[:pinto][:user]}")
        end

        it 'creates pinto_home directory' do
            directory(pinto_home).must_exist.with(:owner, "#{node[:pinto][:user]}")
            directory(pinto_home).must_exist.with(:group, "#{node[:pinto][:group]}")
        end

        it 'creates pinto_home sub directories' do
            pinto_sub_dirs.each do |d|
                directory(d).must_exist.with(:owner, "#{node[:pinto][:user]}")
                directory(d).must_exist.with(:group, "#{node[:pinto][:group]}")
            end
        end

        %w( pinto pintod ).each do |file|
            it "installs #{file} into pinto_home directory" do
                file("#{pinto_home}/bin/#{file}").must_exist.with(:owner, "#{node[:pinto][:user]}")
                file("#{pinto_home}/bin/#{file}").must_exist.with(:group, "#{node[:pinto][:group]}")
                file("#{pinto_home}/bin/#{file}").must_have(:mode, "555")
            end
        end

        it "installs pinto bashrc file" do
            file("#{pinto_home}/etc/bashrc").must_exist.with(:owner, "#{node[:pinto][:user]}")
            file("#{pinto_home}/etc/bashrc").must_exist.with(:group, "#{node[:pinto][:group]}")
            file("#{pinto_home}/etc/bashrc").must_have(:mode, "644")
            file("#{pinto_home}/etc/bashrc").must_include(pinto_home)
        end

        it "installs valid pinto bashrc file" do

            assert_sh "sudo -u #{node[:pinto][:user]} bash -c 'source #{pinto_home}/etc/bashrc'"

            %w( pinto pintod ).each do |file|
                result = assert_sh "sudo -u #{node[:pinto][:user]} bash -c 'source #{pinto_home}/etc/bashrc && which #{file}'"
                assert_includes result, "#{pinto_home}/bin/#{file}"
            end

            result = assert_sh("sudo -u #{node[:pinto][:user]} bash -c 'source #{pinto_home}/etc/bashrc && pinto version'")
            %w( App::Pinto Pinto Pinto::Remote ).each do |l|
                assert_includes result, l
            end
        end


        it "smoke tests on installed pinto client" do
            assert_sh "rm -rf #{pinto_home}/tmp/"
            assert_sh "sudo -u #{node[:pinto][:user]} bash -c 'mkdir  #{pinto_home}/tmp/'"
            assert_sh "sudo -u #{node[:pinto][:user]} bash -c 'source #{pinto_home}/etc/bashrc && pinto -r #{pinto_home}/tmp/ init'"
            assert_sh "sudo -u #{node[:pinto][:user]} bash -c 'source #{pinto_home}/etc/bashrc && pinto -r #{pinto_home}/tmp/ pull Bundler'"

            if node[:pinto][:slow_tests] == '1'
                puts "running slow tests, please be patient,    will take some time ..."    
                result = assert_sh "sudo -u #{node[:pinto][:user]} bash -c 'source #{pinto_home}/etc/bashrc && pinto -r #{pinto_home}/tmp/ list'"
                assert_includes result, '[rf-] Bundler'
            else
                puts "skip slow tests"    
            end

        end

    end    
end

