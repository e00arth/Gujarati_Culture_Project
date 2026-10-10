package com.gujarati.culture.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gujarati.culture.billing.PaywallManager
import com.gujarati.culture.data.CultureRepository
import com.gujarati.culture.models.CulturalModule

@Composable
fun LifestyleScreen(
    repository: CultureRepository,
    paywallManager: PaywallManager
) {
    var showIapManagerDialog by remember { mutableStateOf(false) }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        // Header
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = Color(0xFFFCE4EC)),
            shape = RoundedCornerShape(12.dp)
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.Restaurant,
                    contentDescription = null,
                    tint = Color(0xFFD81B60),
                    modifier = Modifier.size(36.dp)
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text("અસ્મિતા જીવનશૈલી અને સંસ્કૃતિ", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = Color(0xFF880E4F))
                    Text("Dietary Science, Textiles & Architecture", fontSize = 13.sp, color = Color(0xFFAD1457))
                }
                IconButton(onClick = { showIapManagerDialog = true }) {
                    Icon(Icons.Default.Settings, contentDescription = "IAP Settings", tint = Color(0xFF880E4F))
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(repository.lifestyleArticles) { article ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(article.category, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(article.title, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                        Text(article.subtitle, fontStyle = androidx.compose.ui.text.font.FontStyle.Italic, fontSize = 13.sp, color = Color.Gray)

                        Spacer(modifier = Modifier.height(8.dp))
                        Text(article.content, fontSize = 14.sp, lineHeight = 20.sp)

                        Spacer(modifier = Modifier.height(10.dp))
                        article.bulletPoints.forEach { point ->
                            Row(modifier = Modifier.padding(vertical = 2.dp)) {
                                Text("• ", fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                                Text(point, fontSize = 13.sp)
                            }
                        }
                    }
                }
            }

            item {
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedCard(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("Google Play In-App Purchase Controls", fontWeight = FontWeight.Bold)
                        Text("Manage module unlock states or test simulated billing", fontSize = 12.sp, color = Color.Gray)
                        Spacer(modifier = Modifier.height(8.dp))
                        Button(onClick = { showIapManagerDialog = true }) {
                            Icon(Icons.Default.ShoppingCart, contentDescription = null, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text("Open Paywall / Test Billing Manager")
                        }
                    }
                }
            }
        }
    }

    if (showIapManagerDialog) {
        AlertDialog(
            onDismissRequest = { showIapManagerDialog = false },
            title = { Text("In-App Purchase Manager & Testing", fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text("Toggle unlock entitlements for testing in emulator:", fontSize = 13.sp, color = Color.Gray)
                    Spacer(modifier = Modifier.height(12.dp))

                    CulturalModule.values().forEach { module ->
                        val unlocked = paywallManager.isModuleUnlocked(module)
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(module.titleEn, fontSize = 13.sp, modifier = Modifier.weight(1f))
                            if (module.isFree) {
                                Text("FREE", color = Color(0xFF4CAF50), fontWeight = FontWeight.Bold, fontSize = 12.sp)
                            } else {
                                Switch(
                                    checked = unlocked,
                                    onCheckedChange = { checked ->
                                        if (checked) paywallManager.unlockModule(module)
                                        else paywallManager.lockModule(module)
                                    }
                                )
                            }
                        }
                    }

                    Divider(modifier = Modifier.padding(vertical = 8.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("All-Access Heritage Pass:", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        Switch(
                            checked = paywallManager.isAllAccessUnlocked,
                            onCheckedChange = { checked ->
                                if (checked) paywallManager.unlockAllAccess()
                                else paywallManager.resetAllPurchases()
                            }
                        )
                    }

                    Spacer(modifier = Modifier.height(8.dp))
                    TextButton(
                        onClick = {
                            paywallManager.resetAllPurchases()
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Reset All to Default (Locked)", color = Color.Red, fontSize = 12.sp)
                    }
                }
            },
            confirmButton = {
                Button(onClick = { showIapManagerDialog = false }) { Text("Done") }
            }
        )
    }
}
