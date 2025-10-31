LVDStrans_inst : LVDStrans PORT MAP (
		tx_in	 => tx_in_sig,
		tx_inclock	 => tx_inclock_sig,
		tx_coreclock	 => tx_coreclock_sig,
		tx_locked	 => tx_locked_sig,
		tx_out	 => tx_out_sig,
		tx_outclock	 => tx_outclock_sig
	);
