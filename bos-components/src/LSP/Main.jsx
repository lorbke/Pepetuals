State.init({
	address: undefined,
	chainId: undefined,
	tokens: [],
	load: true
});

const contractABI = fetch("https://raw.githubusercontent.com/lorbke/ETHGlobal-New-York/MultiLSP/contract_abi.json");
if (!contractABI.ok) {
	return (<>
		<div className="spinner-border" role="status">
			<span className="visually-hidden">Loading...</span>
		</div>
	</>);
}
const contractData = fetch("https://raw.githubusercontent.com/lorbke/ETHGlobal-New-York/MultiLSP/contract_data.json");
if (!contractData.ok) {
	return (<>
		<div className="spinner-border" role="status">
			<span className="visually-hidden">Loading...</span>
		</div>
	</>);
}

const getAccountId = () => {
	if (ethers !== undefined) {
		return Ethers.send("eth_requestAccounts", [])[0] ?? undefined;
	}
	return undefined;
};
if (getAccountId() != undefined) {
	Ethers.provider()
		.getNetwork()
		.then((chainIdData) => {
		if (chainIdData?.chainId) {
			State.update({
				address: getAccountId(),
				chainId: chainIdData.chainId,
			});
		}
	});
}
// if (!state.address) {
// 	return (<>
// 		<div className="spinner-border" role="status">
// 			<span className="visually-hidden">Loading...</span>
// 		</div>
// 	</>);
// }

const getPositions = () => {
	const ctr = new ethers.Contract(
		JSON.parse(contractData.body)[state.chainId.toString()].contractAddress,
		contractABI.body,
		Ethers.provider().getSigner()
	);
	if (!state.load) return;
	const removeDuplicates = (arr) => {
		let unique = [];
		arr.forEach(element => {
			if (!unique.includes(element)) {
				unique.push(element);
			}
		});
		return unique;
	}
	ctr.getFutureNames().then((token) => {
		const outputBalances = [];
		token = removeDuplicates(token);
		for (let i = 0; i < token.length; i++) {
			const name = ethers.utils.parseBytes32String(token[i]);
			ctr.getBalance({name: token[i], long: true, period: 1, leverage: 1}, state.address).then((balance) => {
				outputBalances.push({name: name, long: true, period: 1, leverage: 1, amount: balance});
				if (outputBalances.length == (token.length * 2)) {
					State.update({ tokens: outputBalances, load: false });
				}
			});
			// ctr.getBalance({name: token[i], long: false, period: 1, leverage: 1}, state.address).then((balance) => {
			// 	outputBalances.push({name: name, long: false, period: 1, leverage: 1, amount: balance});
			// 	if (outputBalances.length == (token.length * 3)) {
			// 		State.update({ tokens: outputBalances, load: false });
			// 	}
			// });
			ctr.getBalance({name: token[i], long: true, period: 4294967295, leverage: 1}, state.address).then((balance) => {
				outputBalances.push({name: name, long: true, period: 4294967295, leverage: 1, amount: balance});
				if (outputBalances.length == (token.length * 2)) {
					State.update({ tokens: outputBalances, load: false });
				}
			});
			// ctr.getBalance({name: token[i], long: true, period: 1, leverage: 2}, state.address).then((balance) => {
			// 	outputBalances.push({name: name, long: true, period: 1, leverage: 2, amount: balance});
			// 	if (outputBalances.length == (token.length * 4)) {
			// 		State.update({ tokens: outputBalances, load: false });
			// 	}
			// });
		}
	});
};
state.address != undefined ? getPositions() : undefined;

const sellPosition = (token) => {
	const ctr = new ethers.Contract(
		JSON.parse(contractData.body)[state.chainId.toString()].contractAddress,
		contractABI.body,
		Ethers.provider().getSigner()
	);
	const ctrusdc = new ethers.Contract(
		"0xF683F18088B78A55F98CFFdd892942530a0d4D1E",
		`[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_account","type":"address"}],"name":"unBlacklist","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"minter","type":"address"}],"name":"removeMinter","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_symbol","type":"string"},{"name":"_currency","type":"string"},{"name":"_decimals","type":"uint8"},{"name":"_masterMinter","type":"address"},{"name":"_pauser","type":"address"},{"name":"_blacklister","type":"address"},{"name":"_owner","type":"address"}],"name":"initialize","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"masterMinter","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"unpause","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"mint","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_amount","type":"uint256"}],"name":"burn","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"minter","type":"address"},{"name":"minterAllowedAmount","type":"uint256"}],"name":"configureMinter","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_newPauser","type":"address"}],"name":"updatePauser","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"paused","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"pause","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"minter","type":"address"}],"name":"minterAllowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"pauser","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_newMasterMinter","type":"address"}],"name":"updateMasterMinter","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"isMinter","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_newBlacklister","type":"address"}],"name":"updateBlacklister","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"blacklister","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"owner","type":"address"},{"name":"spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"currency","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_account","type":"address"}],"name":"blacklist","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_account","type":"address"}],"name":"isBlacklisted","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"minter","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"amount","type":"uint256"}],"name":"Mint","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"burner","type":"address"},{"indexed":false,"name":"amount","type":"uint256"}],"name":"Burn","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"minter","type":"address"},{"indexed":false,"name":"minterAllowedAmount","type":"uint256"}],"name":"MinterConfigured","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"oldMinter","type":"address"}],"name":"MinterRemoved","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"newMasterMinter","type":"address"}],"name":"MasterMinterChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_account","type":"address"}],"name":"Blacklisted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_account","type":"address"}],"name":"UnBlacklisted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"newBlacklister","type":"address"}],"name":"BlacklisterChanged","type":"event"},{"anonymous":false,"inputs":[],"name":"Pause","type":"event"},{"anonymous":false,"inputs":[],"name":"Unpause","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"newAddress","type":"address"}],"name":"PauserChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"previousOwner","type":"address"},{"indexed":false,"name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]`,
		Ethers.provider().getSigner()
	);
	// ctrusdc.approve(JSON.parse(contractData.body)[state.chainId.toString()].contractAddress, ethers.utils.parseEther("10000000000000000000")).then((test) => {
	// 	console.log(test);
	// });
	ctr.sell({name: ethers.utils.formatBytes32String(token.name), long: token.long, period: token.period, leverage: token.leverage}, state.address).then((test) => {
		console.log(test);
	});
};

const MainStyle = styled.div`
	.btn:focus {
		outline: none !important;
		box-shadow: none !important;
	}
`;
return (
	<MainStyle>
		{state.address != undefined && (<div className="table-responsive mt-3 px-4 rounded">
			<table className="table table-hover m-0 text-center">
				<thead>
					<tr>
						<th scope="col">Name</th>
						<th scope="col">Long/Short</th>
						<th scope="col">Amount</th>
						<th scope="col">Perpetual</th>
						<th scope="col">Sell</th>
					</tr>
				</thead>
				<tbody>
					{state.tokens.map((token, i) => (<tr key={i} onClick={onClose}>
						<th scope="row">{token.name}</th>
						<td>{token.long == true ? "Long" : "Short"}</td>
						<td>{token.amount.toString()}</td>
						<td>{token.period == 4294967295 ? "True": "False"}</td>
						<td><button type="button" className="btn btn-primary" onClick={() => sellPosition(token)}>Sell</button></td>
					</tr>))}
				</tbody>
			</table>
		</div>)}
		<Web3Connect
			className={state.address == undefined ? "" : " d-none"}
			connectLabel="Connect with Web3"
		/>
	</MainStyle>
)