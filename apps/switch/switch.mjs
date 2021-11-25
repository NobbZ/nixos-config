#!/usr/bin/env zx

const info = (line) => console.log(chalk.yellow(line));

const trim = (str) => str.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');

console.log(process.argv.slice(2))

console.log(argv)

info("loading nixos names")

const nixosConfigs = JSON.parse(await fs.readFile(argv.nixos))

info("loading home manager names")

const homeConfigs = JSON.parse(await fs.readFile(argv.home))

info("reading hostname");

const hostName = (await fs.readFile("/etc/hostname", "utf8")).trim()

info("reading user");

const user = process.env.USER.trim();

info("finished reading inputs")

const targets = [
    `.#nixos/config/${hostName}`,
    `.#home/config/${user}@${hostName}`,
]

await $`nix build --keep-going --log-format bar-with-logs -v ${targets}`

await fs.readdir('.')
    .then(dirs => Promise.all(dirs
        .filter(name => name.startsWith('result'))
        .map(link => {
            const activate = `./${link}/bin/home-manager-generation`;

            fs.stat(activate)
                .then(() => $`${activate}`)
                .catch(() => {})
        })))

await $`sudo nixos-rebuild switch --flake .#${hostName}`