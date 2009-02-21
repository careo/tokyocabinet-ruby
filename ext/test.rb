#! /usr/bin/ruby

commands = [
            "tchtest.rb write casket 10000",
            "tchtest.rb read casket",
            "tchtest.rb remove casket",
            "tchtest.rb misc casket 1000",
            "tchtest.rb write -tl -as -td casket 10000 10000 1 1",
            "tchtest.rb read -nl casket",
            "tchtest.rb remove -nb casket",
            "tchtest.rb misc -tl -tb casket 1000",
            "tcbtest.rb write casket 10000",
            "tcbtest.rb read casket",
            "tcbtest.rb remove casket",
            "tcbtest.rb misc casket 1000",
            "tcbtest.rb write -tl casket 10000 10 10 100 1 1",
            "tcbtest.rb read -nl casket",
            "tcbtest.rb remove -nb casket",
            "tcbtest.rb misc -tl -tb casket 1000",
            "tcftest.rb write casket 10000",
            "tcftest.rb read casket",
            "tcftest.rb remove casket",
            "tcftest.rb misc casket 1000",
            "tcttest.rb write casket 10000",
            "tcttest.rb read casket",
            "tcttest.rb remove casket",
            "tcttest.rb misc casket 1000",
           ]
num = 1
commands.each do |command|
  rv = system("/usr/bin/ruby #{command} >/dev/null")
  if rv
    printf("%03d/%03d: %s: ok\n", num, commands.size, command)
  else
    printf("%03d/%03d: %s: failed\n", num, commands.size, command)
    exit(1)
  end
  num += 1
end
printf("all ok\n")

system("rm -rf casket")
