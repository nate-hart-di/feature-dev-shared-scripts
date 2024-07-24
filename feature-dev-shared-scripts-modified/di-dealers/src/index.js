#!/usr/bin/env node --harmony

const program = require('commander');
const chalk = require('chalk');
const fetch = require('node-fetch');
const fs = require('fs');
const tabtab = require('tabtab');
const dealers = require('./dealers');



program
  .version('1.0.0')
  .option('-p, --prod', 'Open the production url')
  .option('-u --update')
  .option('-i --install', 'Setup auto complete for dealers')
  .option('-r --remove', 'Remove auto complete for dealers')
  .option('-l --list', 'List both dev & live url for a given slug')
  .parse(process.argv);
if (program.update) {
  fetch('https://dashboard.dealerinspire.com/api/v1/dealer/active_dealers?api_key=56nA2%23dmNZb1%408DFvCmnTuFa5%23DK')
  .then(res => res.json())
  .then((data) => {
    const updatedDealers = data.dealers.map((dealer) => {
      return {
        slug: dealer.slug,
        url: dealer.url,
      };
    });
    fs.writeFile('src/dealers.json', JSON.stringify(updatedDealers), 'utf8', (err) => {
      if (err) {
        throw err;
      }
    })
  });
}
else if (program.install) {
  tabtab.install({
    name: 'did',
    completer: 'did'
  });
} else if (program.remove) {
  tabtab
    .uninstall({
      name: 'did'
    });
} else if(program.list) {
  const slug = process.argv[3];

  const dealer = dealers.find((dealerSearch) => dealerSearch.slug == slug );

  console.log('DEV: ', chalk.cyan(`http://${dealer.slug}.dev.dealerinspire.com`));
  console.log('LIVE: ', chalk.cyan(dealer.url));
} else {
  tabtab.log(dealers.map(dealer => dealer.slug));
}