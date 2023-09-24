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
	ctr.getFutureNames().then((token) => {
		const outputBalances = [];
		for (let i = 0; i < token.length; i++) {
			const name = ethers.utils.parseBytes32String(token[i]);
			ctr.getBalance({name: token[i], long: true, period: 1, leverage: 1}, state.address).then((balance) => {
				outputBalances.push({name: name, long: true, period: 1, leverage: 1, amount: balance});
				if (outputBalances.length == (token.length * 4)) {
					State.update({ tokens: outputBalances, load: false });
				}
			});
			ctr.getBalance({name: token[i], long: false, period: 1, leverage: 1}, state.address).then((balance) => {
				outputBalances.push({name: name, long: false, period: 1, leverage: 1, amount: balance});
				if (outputBalances.length == (token.length * 4)) {
					State.update({ tokens: outputBalances, load: false });
				}
			});
			ctr.getBalance({name: token[i], long: true, period: 4294967295, leverage: 1}, state.address).then((balance) => {
				outputBalances.push({name: name, long: true, period: 4294967295, leverage: 1, amount: balance});
				if (outputBalances.length == (token.length * 4)) {
					State.update({ tokens: outputBalances, load: false });
				}
			});
			ctr.getBalance({name: token[i], long: true, period: 1, leverage: 2}, state.address).then((balance) => {
				outputBalances.push({name: name, long: true, period: 1, leverage: 2, amount: balance});
				if (outputBalances.length == (token.length * 4)) {
					State.update({ tokens: outputBalances, load: false });
				}
			});
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