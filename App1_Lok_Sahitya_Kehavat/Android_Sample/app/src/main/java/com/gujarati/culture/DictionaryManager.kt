package com.gujarati.culture

import android.content.Context
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.io.InputStreamReader

data class WordDefinition(
    val pos: String,
    val definition: String
)

data class GujaratiWord(
    val id: String,
    val word: String,
    val ipa: String,
    val romanization: String,
    val definitions: List<WordDefinition>,
    val example: String
)

object DictionaryManager {
    private var allWords: List<GujaratiWord> = emptyList()

    fun init(context: Context) {
        if (allWords.isNotEmpty()) return
        
        try {
            val inputStream = context.assets.open("gujarati_words.json")
            val reader = InputStreamReader(inputStream)
            val type = object : TypeToken<Map<String, List<String>>>() {}.type
            val jsonMap: Map<String, List<String>> = Gson().fromJson(reader, type)
            
            allWords = jsonMap.mapNotNull { (id, array) ->
                if (array.size >= 5) {
                    GujaratiWord(
                        id = id,
                        word = array[0],
                        ipa = array[1],
                        romanization = array[2],
                        definitions = listOf(WordDefinition(pos = array[3], definition = array[4])),
                        example = if (array.size > 5) array[5] else ""
                    )
                } else null
            }
            reader.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun getRandomWords(limit: Int = 10): List<GujaratiWord> {
        if (allWords.isEmpty()) return emptyList()
        return allWords.shuffled().take(limit)
    }
}
