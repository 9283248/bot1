import urllib.parse
from aiogram import Bot, Dispatcher, types, F
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
from aiogram.enums import ParseMode
from aiogram.fsm.context import FSMContext
from aiogram.fsm.storage.memory import MemoryStorage
from aiogram.fsm.state import State, StatesGroup
from aiogram.filters import CommandStart
from aiogram.utils.keyboard import InlineKeyboardBuilder
from aiogram import Router
from aiogram.client.default import DefaultBotProperties
import asyncio

API_TOKEN = '7533715681:AAH2fMRIF37JLG6kn8Osux_TVFSvNQHkzao'  # <-- замени на токен

router = Router()
user_data = {}

class LinkForm(StatesGroup):
    awaiting_text = State()
    awaiting_link = State()
    awaiting_account = State()


def build_link(data):
    message = f"{data.get('text', 'здравствуйте, я по поводу')} {data.get('link', '')}"
    encoded = urllib.parse.quote(message)
    return f"https://t.me/{data.get('account', 'svetlanapak_kuturi')}?text={encoded}"


def get_keyboard(link):
    kb = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🔗 Открыть ссылку", url=link)],
        [
            InlineKeyboardButton(text="✏ Заменить текст", callback_data="change_text"),
            InlineKeyboardButton(text="🔁 Заменить ссылку", callback_data="change_link")
        ],
        [InlineKeyboardButton(text="👤 Заменить аккаунт", callback_data="change_account")],
        [
            InlineKeyboardButton(text="🆕 Начать новую", callback_data="reset"),
            InlineKeyboardButton(text="🏁 Старт", callback_data="start")
        ]
    ])
    return kb


@router.message(CommandStart())
async def cmd_start(message: types.Message, state: FSMContext):
    await state.clear()
    await state.update_data(text="здравствуйте, я по поводу", account="svetlanapak_kuturi", link="")
    await message.answer("Привет! Отправьте ссылку, с которой хотите создать сообщение.")


@router.message(F.text.startswith("http"))
async def handle_link(message: types.Message, state: FSMContext):
    await state.update_data(link=message.text.strip())
    data = await state.get_data()
    link = build_link(data)
    await message.answer(f"Вот ваша ссылка:\n{link}", reply_markup=get_keyboard(link))


@router.callback_query(F.data == "change_text")
async def change_text(call: types.CallbackQuery, state: FSMContext):
    await call.message.answer("Введите новый текст для сообщения:")
    await state.set_state(LinkForm.awaiting_text)
    await call.answer()


@router.callback_query(F.data == "change_link")
async def change_link(call: types.CallbackQuery, state: FSMContext):
    await call.message.answer("Введите новую ссылку:")
    await state.set_state(LinkForm.awaiting_link)
    await call.answer()


@router.callback_query(F.data == "change_account")
async def change_account(call: types.CallbackQuery, state: FSMContext):
    await call.message.answer("Введите новый логин Telegram-аккаунта (без @):")
    await state.set_state(LinkForm.awaiting_account)
    await call.answer()


@router.callback_query(F.data == "reset")
async def reset(call: types.CallbackQuery, state: FSMContext):
    await cmd_start(call.message, state)
    await call.answer("Данные сброшены.")


@router.callback_query(F.data == "start")
async def restart(call: types.CallbackQuery):
    await call.message.answer("Чтобы создать новую ссылку, отправьте её заново.")
    await call.answer()


@router.message(LinkForm.awaiting_text)
async def set_text(message: types.Message, state: FSMContext):
    await state.update_data(text=message.text.strip())
    data = await state.get_data()
    link = build_link(data)
    await message.answer(f"Обновлённая ссылка:\n{link}", reply_markup=get_keyboard(link))
    await state.clear()


@router.message(LinkForm.awaiting_link)
async def set_link(message: types.Message, state: FSMContext):
    if not message.text.startswith("http"):
        await message.answer("Ссылка должна начинаться с http или https.")
        return
    await state.update_data(link=message.text.strip())
    data = await state.get_data()
    link = build_link(data)
    await message.answer(f"Обновлённая ссылка:\n{link}", reply_markup=get_keyboard(link))
    await state.clear()


@router.message(LinkForm.awaiting_account)
async def set_account(message: types.Message, state: FSMContext):
    await state.update_data(account=message.text.strip())
    data = await state.get_data()
    link = build_link(data)
    await message.answer(f"Обновлённая ссылка:\n{link}", reply_markup=get_keyboard(link))
    await state.clear()


async def main():
    bot = Bot(token=API_TOKEN, default=DefaultBotProperties(parse_mode=ParseMode.HTML))
    dp = Dispatcher(storage=MemoryStorage())
    dp.include_router(router)
    await dp.start_polling(bot)

if __name__ == '__main__':
    asyncio.run(main())
