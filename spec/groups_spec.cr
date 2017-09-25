require "tempfile"

describe Acl::Groups do
  it "advanced test for users permitted?" do
    g = Acl::Group.new(
      name: "root",
      permissions: {
        "/public/~/*"      => Acl::Perm::Write,
        "/notpublic/\\~/*" => Acl::Perm::Write,
      },
      default: Acl::Perm::None
    )
    groups = Acl::Groups.new Tempfile.new("spec").to_s
    groups.add g
    connected_user = Acl::User.new "root", "toor", ["root"]
    perm = groups.permitted? connected_user, "/public/root/any", Acl::Perm::Write, {/~/ => connected_user.name}
    perm.should eq true
    perm = groups.permitted? connected_user, "/public/other/any", Acl::Perm::Write, {/~/ => connected_user.name}
    perm.should eq false
    # test with backslash
    perm = groups.permitted? connected_user, "/notpublic/root/any", Acl::Perm::Write, {/~/ => connected_user.name}
    perm.should eq false
  end
end
