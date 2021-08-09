#!/usr/bin/env zx

console.log(process.argv.slice(2))

console.log(argv)

console.log("loading nixos names")

const nixosConfigs = JSON.parse(await fs.readFile(argv.nixos))

console.log("loading home manager names")

const homeConfigs = JSON.parse(await fs.readFile(argv.home))

console.log("finished reading inputs")

nixosConfigs.map(val => console.log(val))
homeConfigs.map(val => console.log(val))