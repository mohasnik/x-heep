// Copyright 2026 Huawei Technologies Co., Ltd.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "core_v_mini_mcu.h"

// VPK180 maps the PL DDR AXI window at 0xC000_0000 to PS physical DDR
// 0x0000_0009_C000_0000, with a 1 GiB range. The X-HEEP external slave
// range generated from configs/general.hjson must match that AXI window.
#define VPK180_DDR_AXI_WINDOW_BASE 0xC0000000UL
#define VPK180_DDR_PHYS_BASE       0x00000009C0000000ULL

// Read the first 16 32-bit words available in the generated external range.
#define DDR_READ_WORDS 16

#if EXT_SLAVE_START_ADDRESS != VPK180_DDR_AXI_WINDOW_BASE
#error "EXT_SLAVE_START_ADDRESS must match the VPK180 DDR AXI window base"
#endif

#if EXT_SLAVE_SIZE < (DDR_READ_WORDS * 4ULL)
#error "External slave range is too small for the DDR read test"
#endif

#define XHEEP_DDR_ADDR ((uint32_t)EXT_SLAVE_START_ADDRESS)

int main(void)
{
    volatile uint32_t *ddr = (volatile uint32_t *)(uintptr_t)XHEEP_DDR_ADDR;

    printf("X-HEEP DDR read test\n");
    printf("X-HEEP DDR window base: 0x%08x\n", XHEEP_DDR_ADDR);
    printf("PS DDR physical base  : 0x%08x%08x\n",
           (uint32_t)(VPK180_DDR_PHYS_BASE >> 32), (uint32_t)VPK180_DDR_PHYS_BASE);
    printf("Reading %u words:\n", (unsigned)DDR_READ_WORDS);

    for (uint32_t i = 0; i < DDR_READ_WORDS; i++) {
        uint64_t ps_addr = VPK180_DDR_PHYS_BASE + 4u * i;
        uint32_t xheep_addr = XHEEP_DDR_ADDR + 4u * i;
        uint32_t value = ddr[i];
        printf("  PS[0x%08x%08x] X-HEEP[0x%08x] = 0x%08x\n",
               (uint32_t)(ps_addr >> 32), (uint32_t)ps_addr, xheep_addr, value);
    }

    printf("Done.\n");
    return EXIT_SUCCESS;
}
